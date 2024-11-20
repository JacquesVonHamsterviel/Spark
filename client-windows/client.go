package main

import (
	"Spark/client/config"
	"Spark/client/core"
	"Spark/utils"
	"bytes"
	"crypto/aes"
	"crypto/cipher"
	"golang.org/x/sys/windows/svc"
	"golang.org/x/sys/windows/svc/eventlog"
	"log"
	"math/big"
	"os"
	"strings"
)

var elog *eventlog.Log

type myService struct{}

func (m *myService) Execute(args []string, r <-chan svc.ChangeRequest, s chan<- svc.Status) (svcSpecificEC bool, exitCode uint32) {
	const cmdsAccepted = svc.AcceptStop | svc.AcceptShutdown
	s <- svc.Status{State: svc.StartPending}
	s <- svc.Status{State: svc.Running, Accepts: cmdsAccepted}

	// 服务启动后调用主业务逻辑
	go core.Start()

loop:
	for {
		select {
		case c := <-r:
			switch c.Cmd {
			case svc.Stop, svc.Shutdown:
				s <- svc.Status{State: svc.StopPending}
				break loop
			default:
				continue
			}
		}
	}

	s <- svc.Status{State: svc.Stopped}
	return
}

func init() {
	if len(strings.Trim(config.ConfigBuffer, "\x19")) == 0 {
		os.Exit(1)
		return
	}

	// Convert first 2 bytes to int, which is the length of the encrypted config.
	dataLen := int(big.NewInt(0).SetBytes([]byte(config.ConfigBuffer[:2])).Uint64())
	if dataLen > len(config.ConfigBuffer)-2 {
		os.Exit(1)
		return
	}
	cfgBytes := utils.StringToBytes(config.ConfigBuffer, 2, 2+dataLen)
	cfgBytes, err := decrypt(cfgBytes[16:], cfgBytes[:16])
	if err != nil {
		os.Exit(1)
		return
	}
	err = utils.JSON.Unmarshal(cfgBytes, &config.Config)
	if err != nil {
		os.Exit(1)
		return
	}
	if strings.HasSuffix(config.Config.Path, "/") {
		config.Config.Path = config.Config.Path[:len(config.Config.Path)-1]
	}
}

func main() {
	isInteractive, err := svc.IsAnInteractiveSession()
	if err != nil {
		log.Fatalf("failed to determine if we are running in an interactive session: %v", err)
	}

	if !isInteractive {
		// 在服务模式下运行
		runService("MyGoService", false)
		return
	}

	// 如果是交互模式（调试或者本地运行），直接执行核心逻辑
	core.Start()
}

func runService(name string, isDebug bool) {
	var err error
	if !isDebug {
		elog, err = eventlog.Open(name)
		if err != nil {
			return
		}
		defer elog.Close()
		elog.Info(1, name+" service starting")
	}

	run := svc.Run
	if err = run(name, &myService{}); err != nil {
		if elog != nil {
			elog.Error(1, name+" service failed: "+err.Error())
		}
		return
	}

	if elog != nil {
		elog.Info(1, name+" service stopped")
	}
}

func decrypt(data []byte, key []byte) ([]byte, error) {
	// MD5[16 bytes] + Data[n bytes]
	dataLen := len(data)
	if dataLen <= 16 {
		return nil, utils.ErrEntityInvalid
	}
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}
	stream := cipher.NewCTR(block, data[:16])
	decBuffer := make([]byte, dataLen-16)
	stream.XORKeyStream(decBuffer, data[16:])
	hash, _ := utils.GetMD5(decBuffer)
	if !bytes.Equal(hash, data[:16]) {
		return nil, utils.ErrFailedVerification
	}
	return decBuffer[:dataLen-16], nil
}
