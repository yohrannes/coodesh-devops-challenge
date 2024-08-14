# Devops na Google Cloud

Este projeto consiste em realizar provisionamento de um servidor e hospedagem de website na Google Cloud, utilizando CI-CD e infra-as-code, com diversas ferramentas e configurações na melhor prática possível segunda as recomendações da GCP com segurança,grupos de segurança e configurações de rede provisionado totalmente por código.

## Tecnologias utilizadas

### Ferramentas
- Docker
- Terraform

### Linguagens
- Python
- Shell script

### Framework
- Flask

## Instruções de instalação e provisionamento

### Instalação do terraform no ubuntu

Caso possua outro sistema operacional verifique a documentação oficial neste [link](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
   
- [ ] Conferindo sistema e pacotes necessários.
```
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
```
- [ ] Instalando a chave GPG
```
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
```
- [ ] Adicionando repositorio oficial da Hashicorp
```
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
```
- [ ] Instalando o terraform
```
sudo apt update; sudo apt-get install terraform
```
- [ ] Caso queira, confira a instalação
```
terraform -v
```

- Não esqueça o [.gitignore](https://www.toptal.com/developers/gitignore)

## Passos na execução do desafio.

### 1 - Configuração do Servidor

1. Configuração de IAM com segurança na GCP

2. Configuração da redes para o Servidor

3. Configuração do servidor na GCP (mais barato possivel) com Ubuntu LTS.

4. Instalação de configuração de softwares recomendados sob as perspectivas de segurança, desempenho, backup e monitorização.

5. Configuração do nginx para servir uma página web HTML estática.

### 2 – Infra as Code

1. Utilizando o Terraform

Projeto executando em um servidor e com as melhores práticas de segurança com grupos de segurança e as configurações de rede criando completamente por código.

### 3 – Continuous Delivery

Pipeline de apoio para a entrega contínua da aplicação de monitorização construída na Parte 2 no servidor configurado na Parte 1.

Descrever a pipeline utilizando um diagrama de fluxo e explicar o objetivo e o processo de seleção usado em cada uma das ferramentas e técnicas específicas que compõem a sua pipeline. 