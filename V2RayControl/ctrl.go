package v2rayControl

import (
	"fmt"

	core "github.com/v2fly/v2ray-core/v5"
	_ "github.com/v2fly/v2ray-core/v5/main/distro/all" // required for loading configuration loaders (we use only "JSON")
)

type Instance struct {
	server *core.Instance
}

func Start(jsonConfig string) (*Instance, error) {
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

	return &Instance{server: server}, nil
}

func Stop(instance *Instance) error {
	if instance.server == nil {
		return fmt.Errorf("server instance is nil")
	}

	return instance.server.Close()
}
