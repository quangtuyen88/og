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
git clone -b v0.1.0 https://github.com/0glabs/0g-chain.git
./0g-chain/networks/testnet/install.sh
source .profile


0gchaind config keyring-backend test
0gchaind config chain-id zgtendermint_16600-1
0gchaind config node tcp://localhost:14257
0gchaind init NodeName --chain-id zgtendermint_16600-1


sed -i \
  -e 's|^chain-id *=.*|chain-id = "zgtendermint_16600-1"|' \
  -e 's|^keyring-backend *=.*|keyring-backend = "test"|' \
  -e 's|^node *=.*|node = "tcp://localhost:14257"|' \
  $HOME/.0gchaind/config/client.toml


### downlaod genesis file
wget -P $HOME/.0gchaind/config https://github.com/0glabs/0g-chain/releases/download/v0.1.0/genesis.json

#PEERS="1248487ea585730cdf5d3c32e0c2a43ad0cda973@peer-zero-gravity-testnet.trusted-point.com:26326" && \
SEEDS="c4d619f6088cb0b24b4ab43a0510bf9251ab5d7f@54.241.167.190:26656,44d11d4ba92a01b520923f51632d2450984d5886@54.176.175.48:26656,f2693dd86766b5bf8fd6ab87e2e970d564d20aff@54.193.250.204:26656,f878d40c538c8c23653a5b70f615f8dccec6fb9f@54.215.187.94:26656"
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.0gchaind/config/config.toml

##sed -i -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.0gchaind/config/config.toml


sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://0.0.0.0:14258\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:14257\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:14260\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:14256\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":14266\"%" $HOME/.0gchaind/config/config.toml
sed -i.bak -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://0.0.0.0:14217\"%; s%^address = \":8080\"%address = \":14280\"%; s%^address = \"localhost:9090\"%address = \"0.0.0.0:14290\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:14291\"%; s%:8545%:14245%; s%:8546%:14246%; s%:6065%:14265%" $HOME/.0gchaind/config/app.toml

# config pruning
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.0gchaind/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.0gchaind/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" $HOME/.0gchaind/config/app.toml

# set minimum gas price, enable prometheus and disable indexing
sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0.005u0G"|g' $HOME/.0gchaind/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.0gchaind/config/config.toml
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.0gchaind/config/config.toml


sudo tee /etc/systemd/system/0gchaind.service > /dev/null <<EOF
[Unit]
Description=0gchaind Protocol
After=network-online.target
[Service]
User=root
ExecStart=$(which 0gchaind) start --home $HOME/.0gchaind
Restart=always
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

cd $HOME

sudo systemctl daemon-reload
sudo systemctl enable 0gchaind
sudo systemctl restart 0gchaind && sudo journalctl -u 0gchaind -f --no-hostname -o cat


echo "===================Install Success==================="

else

echo "Not installed"

fi
