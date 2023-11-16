package main

import (
	"fmt"
	"time"
	"v2rayControl"
)

func main() {
	fmt.Println("v2rayControl test")

	if err := v2rayControl.Start(JsonCfgTest); err != nil {
		fmt.Println(err)
		return
	}

	fmt.Println("Started")
	time.Sleep(time.Second * 5)

	fmt.Println("Stopping...")
	if err := v2rayControl.Stop(); err != nil {
		fmt.Println(err)
		return
	}

	time.Sleep(time.Second)
	fmt.Println("Done")
}

const JsonCfgTest = `
{
	"log": {
		"loglevel": "debug"
	},
	"inbounds": [
		{
			"port": "53142",
			"protocol": "dokodemo-door",
			"settings": {
				"address": "91.232.28.116",
				"port": 15351,
				"network": "udp"
			}
		}
	],
	"outbounds": [
		{
			"tag": "proxy",
			"protocol": "vmess",
			"settings": {
				"vnext": [
					{
						"address": "91.232.28.119",
						"port": 2049,
						"users": [
							{
								"id": "27de860d-5601-412d-8b71-baa048a94b98",
								"alterId": 0,
								"security": "none"
							}
						]
					}
				]
			},
			"streamSettings": {
				"network": "quic",
				"security": "tls",
				"quicSettings": {
					"security": "",
					"key": "",
					"header": {
						"type": "srtp"
					}
				},
				"tlsSettings": {
					"serverName": "ua2.gw.inet-telecom.com"
				}
			}
		}
	]
}
`
