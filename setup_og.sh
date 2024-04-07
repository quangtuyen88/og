#!/bin/bash
clear

if [[ ! -f "$HOME/.bash_profile" ]]; then
    touch "$HOME/.bash_profile"
fi

if [ -f "$HOME/.bash_profile" ]; then
    source $HOME/.bash_profile
fi

echo "===========EvmoS Protocol Install Easy======= " && sleep 1

read -p "Do you want run node OG Protocol ? (y/n): " choice

if [ "$choice" == "y" ]; then

sudo apt update && sudo apt upgrade -y
sudo apt install make curl git wget htop tmux build-essential jq make lz4 gcc unzip -y

#Install GO
ver="1.21.5"
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile
go version


sudo apt install unzip -y
cd $HOME
git clone -b v1.0.0-testnet https://github.com/0glabs/0g-evmos.git
./0g-evmos/networks/testnet/install.sh
source .profile


evmosd config keyring-backend test
evmosd config chain-id zgtendermint_9000-1
evmosd config node tcp://localhost:14257
evmosd init NodeName --chain-id zgtendermint_9000-1


sed -i \
  -e 's|^chain-id *=.*|chain-id = "zgtendermint_9000-1"|' \
  -e 's|^keyring-backend *=.*|keyring-backend = "test"|' \
  -e 's|^node *=.*|node = "tcp://localhost:14257"|' \
  $HOME/.evmosd/config/client.toml


### downlaod genesis file
wget https://github.com/0glabs/0g-evmos/releases/download/v1.0.0-testnet/genesis.json -O $HOME/.evmosd/config/genesis.json

PEERS="1248487ea585730cdf5d3c32e0c2a43ad0cda973@peer-zero-gravity-testnet.trusted-point.com:26326" && \
SEEDS="8c01665f88896bca44e8902a30e4278bed08033f@54.241.167.190:26656,b288e8b37f4b0dbd9a03e8ce926cd9c801aacf27@54.176.175.48:26656,8e20e8e88d504e67c7a3a58c2ea31d965aa2a890@54.193.250.204:26656,e50ac888b35175bfd4f999697bdeb5b7b52bfc06@54.215.187.94:26656" && \
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.evmosd/config/config.toml




sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://0.0.0.0:14258\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:14257\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:14260\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:14256\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":14266\"%" $HOME/.evmosd/config/config.toml
sed -i.bak -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://0.0.0.0:14217\"%; s%^address = \":8080\"%address = \":14280\"%; s%^address = \"localhost:9090\"%address = \"0.0.0.0:14290\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:14291\"%; s%:8545%:14245%; s%:8546%:14246%; s%:6065%:14265%" $HOME/.evmosd/config/app.toml


###set gas
sed -i "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.00252aevmos\"/" $HOME/.evmosd/config/app.toml

sudo tee /etc/systemd/system/evmosd.service > /dev/null <<EOF
[Unit]
Description=evmosd Protocol
After=network-online.target
[Service]
User=root
ExecStart=$(which evmosd) start --home $HOME/.evmosd
Restart=always
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

cd $HOME

sudo systemctl daemon-reload
sudo systemctl enable evmosd
sudo systemctl restart evmosd && sudo journalctl -u evmosd -f --no-hostname -o cat


echo "===================Install Success==================="

else

echo "Not installed"

fi
