# Devops na Google Cloud

Este projeto consiste em realizar provisionamento de um servidor Ubuntu 22.04 LTS e hospedá-lo no na Google Cloud, juntamente com na criação de VPN, Subregion e um bucket para armazenar o estado da infraestrutura; Utilizando CI-CD do gitlab para a pipeline e infra-as-code com o terraform, com diversas ferramentas e configurações na melhor prática possível segundo as recomendações da GCP com segurança, provisionadas totalmente por código.

## Tecnologias utilizadas

### Ferramentas
- Docker
- Terraform
- Nginx

### Linguagens
- Python
- Shell script

### Framework
- Flask

## Instruções de instalação e provisionamento

### 1 - Instalação do terraform no ubuntu

Caso possua outro sistema operacional verifique a documentação oficial neste [link](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
   
- [ ] Confira o sistema e pacotes necessários.
```
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
```
- [ ] Instale a chave GPG
```
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
```
- [ ] Adicione o repositorio oficial da Hashicorp
```
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
```
- [ ] Instale o terraform
```
sudo apt update; sudo apt-get install terraform
```
- [ ] Caso queira, confira a instalação
```
terraform -v
```
### 2 - Instalação do GCP CLI
Mais informações na documentação oficial neste [link](https://cloud.google.com/sdk/docs/install-sdk?hl=pt-br&cloudshell=false#deb)

- [ ] Confira pacotes e programas antes da instalação
```
sudo apt-get install apt-transport-https ca-certificates gnupg curl
```
- [ ] Importe a chave pública do Google Cloud.
```
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
```
- [ ] Adicione o URI de distribuição da CLI gcloud como uma origem de pacote.
```
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
```
- [ ] Atualize e instale a gcloud CLI.
```
sudo apt-get update && sudo apt-get install google-cloud-cli
```
- [ ] Execute gcloud init para começar.
```
gcloud init
```
- [ ] Aceite a opção de fazer login com sua conta de usuário do Google.
```
To continue, you must log in. Would you like to log in (Y/n)? Y
```
- [ ] No seu navegador, faça login na sua conta de usuário do Google quando solicitado e clique em Permitir para permitir acesso aos recursos do Google Cloud.
- [ ] No prompt de comando, selecione um projeto do Google Cloud na lista. de projetos em que você tem permissões de Proprietário ou Editor.
```
Pick cloud project to use:
 [1] [my-project-1]
 [2] [my-project-2]
 ...
 Please enter your numeric choice:
```

Após isso você já estará autenticado com o CLI!

### 3 - Autenticação do Terraform com a GCP

  Primeiramente precisaremos fazer a criação de uma service account para podermos fazer o provisionamento no terraform da VPS e bucket, utilizando a recomendação amplamete utilizada em diversos casos garantindo isolamento de credenciais (service account), mínimos priivlégios e facilitando auditorias, com total conformidade com as políticas de segurança.

- [ ] Crie uma service account
```
gcloud iam service-accounts create sva-terraform-coodesh --display-name "sva-terraform-coodesh"
```
- [ ] Liste as service accounts e copie o email da service account desejada.
```
gcloud iam service-accounts list
```
- [ ] Gere o arquivo de chave de service account (json)
```
gcloud iam service-accounts keys create key.json --iam-account <email-da-service-account-desejada>
```
- [ ] Setando variáveis de ambiente do project-id, credenciasi necessárias e região onde estará a VPS.
```
export GOOGLE_CLOUD_PROJECT=<seu-project-id>;
export GOOGLE_APPLICATION_CREDENTIALS=$PWD/key.json;
export GOOGLE_REGION=us-central1;
export GOOGLE_ZONE=us-central1-a;
```
- [ ] Pegue o id do seu projeto e copie-o
```
gcloud projects list
```
- [ ] Liberar permissões de compute, network e firewall para a service account, mais informações na documentação oficial neste [link.](https://cloud.google.com/iam/docs/understanding-roles#compute-engine-roles)
```
export SERVICE_ACCOUNT_EMAIL="<email-da-service-account>";
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
  --member "serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
  --role "roles/compute.instanceAdmin.v1" && \
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
  --member "serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
  --role "roles/compute.networkAdmin" && \
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
  --member "serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
  --role "roles/cloudbuild.integrationsOwner" && \
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
  --member "serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
  --role "roles/vpcaccess.serviceAgent" && \
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
  --member "serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
  --role "roles/storage.admin" && \
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
  --member "serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
  --role "roles/compute.securityAdmin"

```

- [ ] Inicializando o terraform, e provisionando a VPS.
```
terraform init
terraform plan
terraform apply
```
- [ ] Verificar qual é o ip publico da VPS e copiá-lo(EXTERNAL_IP).
```
gcloud compute instances list
```
  Após isso será necessário aguardar em torno de 8-10 minutos (devido a baixa potência da VPS) e acessar o link com http no navegador ou via linha de comando mesmo com o curl (lembrando no momento é http e não https ainda).
```
curl http://<ip-publico-da-vps>
```
  Demais passos para a configuração , teste e provisionamento serão feitos a partir da pipeline do gitlab.

## Diagrama da infraestrutua

![diagrama-infra](./diagrama-infra.png)

## Fluxograma da pipelina

![fluxgrama-pipeline](./fluxograma-pipeline.png)

## Descritivo da Pipeline

### Test

  Este estágio é composto dois jobs, o primeiro (install-nginx-test) é onde verificamos a instalação do nginx em uma imagem docker que seja do mesmo sistema operacional (ubuntu),versão (22.04) e arquitetura do processador da VPS na GCP, que será provisionada (amd64 que já é a utilizada no executor do gitlab). Imagem que executará o mesmo script de inicialização que é especificado na criação da VPS, com uma diferença na execução (install-nginx) pois realizaremos o teste somente da function install-nginx do script que será utilizada na VPS da GCP. Esta function consiste resumidamente na instalação do nginx e configuração do mesmo como proxy para redirecionar a porta 80 da VPS para a 5000 onde se encontrará rodando o container da aplicação. Caso dê tudo certo ou não, será informado.

  O segundo job neste estágio de test é o check-image-security, onde basicamente é feita a instalação da ferramenta trivy em uma imagem que simulará a VPS ubuntu na GCP, ferramenta amplamente utilizada para verificar vulnerabilidades em imagens dockers, onde verificará e informará o estado de segurança da imagem da aplicação na pipeline e salvará em um arquivo de texto(trivy image yohrannes/coodesh-challenge > trivy-scan.txt), caso encontre uma vulnerabilidade do tipo HIGH será informado.

### Build

  Neste estágio temos somente um job onde será provisionado uma imagem do docker (docker:27.1.2), utilizando o serviço do docker dind, que nos ajudará a verificar o build da imagem da aplicação, caso tudo ocorra bem no estágio anterior e no build da imagem, deverá realizar o pull, enviando a imagem da forma correta para o registry do docker (dockerhub).

### Deploy

  Este é o ultimo estágio onde será realizado o deploy de toda a infraestrutura e instalação da VPS, caso tudo ocorra bem.

  Primeiramente para executarmos este job utilizaremos a imagem do docker, com o serviço do docker dind para realizarmos o build da imagem oficial da hashicorp(terraform) que utilizaremo para executar os comandos necessários para provisionar a infraestrutura. Após isso criamos um diretório para fazer a autenticação da nossa service account com o provider da google, utilizando a chave key.json para fazer a autenticação.

  Adiante seguimos com o comando terraform init e depois com o terraform apply, onde provisionamos a infraestrutura por completo, após toda a infraestrutura ser provisionada adicionamos ao arquivo main.tf do terraform a informação de que ele precisará armazenar o estado da infraestrutura dentro do bucket já criado (coodesh-bucket) sendo assim, temos o nosso backup caso ocorra algum problema em qualquer estado do provisionamento da infraestrutura, ou perca de arquivos, sabemos que o estado de toda a infra está dentro do bucket protejido. Caso dê tudo certo ou não, será informado.

### Observações

  As variáveis de ambiente mais sigilosas são passadas diretamente na conta do gitlab sendo protegidas e mascaradas.

  Por questões de tempo ainda não foi provisionado uma forma para o provisionamente de uma infra de monitoramento, porém a intenção era dentro da VPS, além de rodar a imagem da aplicação, instalar o node exporter e o prometheus na VPS, e o node exporter na imagem da a plicação, mandando assim métricas de estado de cpu, ram e disco para algum monitorador externo de preferência (outra VPS) para monitorar toda a infra.

## Passos na executados no desafio.

### 1 - Configuração do Servidor

1. Configuração de IAM com segurança na GCP*
2. Configuração da redes para o Servidor*
3. Configuração do servidor na GCP (mais barato possivel) com Ubuntu LTS.*
4. Instalação de configuração de softwares recomendados sob as perspectivas de segurança(docker,nginx-proxy), desempenho(alpine), backup e monitorização.*
5. Configuração do nginx para servir uma página web HTML estática.*

### 2 - Infra as Code

1. Utilizando o Terraform*

Projeto executando em um servidor e com as melhores práticas de segurança com grupos de segurança(service-account) e as configurações de rede criando completamente por código.*

### 3 - Continuous Delivery

Pipeline de apoio para a entrega contínua da aplicação de monitorização construída na Parte 2 no servidor configurado na Parte 1.*

Descrever a pipeline utilizando um diagrama de fluxo e explicar o objetivo e o processo de seleção usado em cada uma das ferramentas e técnicas específicas que compõem a sua pipeline. *
