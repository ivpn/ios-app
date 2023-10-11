package v2rayControl

import (
	"fmt"
	"sync"

	core "github.com/v2fly/v2ray-core/v5"

	// Mandatory features
	_ "github.com/v2fly/v2ray-core/v5/app/dispatcher"
	_ "github.com/v2fly/v2ray-core/v5/app/proxyman/inbound"
	_ "github.com/v2fly/v2ray-core/v5/app/proxyman/outbound"

	// Inbound and outbound proxies
	_ "github.com/v2fly/v2ray-core/v5/proxy/blackhole"
	_ "github.com/v2fly/v2ray-core/v5/proxy/dns"
	_ "github.com/v2fly/v2ray-core/v5/proxy/dokodemo"
	_ "github.com/v2fly/v2ray-core/v5/proxy/freedom"
	_ "github.com/v2fly/v2ray-core/v5/proxy/http"
	_ "github.com/v2fly/v2ray-core/v5/proxy/shadowsocks"
	_ "github.com/v2fly/v2ray-core/v5/proxy/socks"
	_ "github.com/v2fly/v2ray-core/v5/proxy/trojan"
	_ "github.com/v2fly/v2ray-core/v5/proxy/vless/inbound"
	_ "github.com/v2fly/v2ray-core/v5/proxy/vless/outbound"
	_ "github.com/v2fly/v2ray-core/v5/proxy/vmess/inbound"
	_ "github.com/v2fly/v2ray-core/v5/proxy/vmess/outbound"

	// Transport headers
	_ "github.com/v2fly/v2ray-core/v5/transport/internet/headers/http"
	_ "github.com/v2fly/v2ray-core/v5/transport/internet/headers/noop"
	_ "github.com/v2fly/v2ray-core/v5/transport/internet/headers/srtp"
	_ "github.com/v2fly/v2ray-core/v5/transport/internet/headers/tls"
	_ "github.com/v2fly/v2ray-core/v5/transport/internet/headers/utp"
	_ "github.com/v2fly/v2ray-core/v5/transport/internet/headers/wechat"
	_ "github.com/v2fly/v2ray-core/v5/transport/internet/headers/wireguard"

	// JSON, TOML, YAML config support
	_ "github.com/v2fly/v2ray-core/v5/main/formats"
)

type Instance struct {
	server *core.Instance
}

var (
	locker        sync.Mutex
	v2rayInstance *Instance
)

func Start(jsonConfig string) (*Instance, error) {
	locker.Lock()
	defer locker.Unlock()

	config, err := core.LoadConfig("json", []byte(jsonConfig))
	if err != nil {
		return nil, err
	}

	server, err := core.New(config)
	if err != nil {
		return nil, err
	}

	err = server.Start()
	if err != nil {
		return nil, err
	}

	v2rayInstance = &Instance{server: server}

	return v2rayInstance, nil
}

func Stop(instance *Instance) error {
	locker.Lock()
	defer locker.Unlock()

	if instance.server == nil {
		return fmt.Errorf("server instance is nil")
	}

	if v2rayInstance != nil {
		v2rayInstance.server.Close()
		v2rayInstance = nil
	}

	if instance != nil {
		err := instance.server.Close()
		if err != nil {
			return err
		}
		instance = nil
	}

	return nil
}
