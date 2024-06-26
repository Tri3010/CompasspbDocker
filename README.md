
# CompasspbDocker
Repositório criado para atividade Docker do Programa de Bolsas Compass DevSecOps 2024

Este projeto visa facilitar a instalação e configuração de um ambiente WordPress na AWS, utilizando Docker ou Containerd como runtime de contêineres. O objetivo é fornecer uma solução escalável e altamente disponível, integrando serviços como Amazon RDS, Amazon EFS e AWS Load Balancer.

## Pré-requisitos

Antes de começar, é necessário garantir que você tenha:

- Uma conta na AWS com permissões para criar e gerenciar recursos.
- Acesso à AWS CLI ou ao console da AWS.
- Conhecimento básico de Docker e AWS.


## Pontos de Atenção

- Evite o uso de IPs públicos para saída dos serviços WordPress.
- Sugira que o tráfego de internet seja roteado através do Load Balancer.
- Utilize o EFS para armazenar os arquivos estáticos do WordPress.
- Deixe a escolha entre Dockerfile e Docker Compose para os integrantes do projeto.
- Certifique-se de demonstrar o funcionamento da aplicação WordPress, incluindo a tela de login.
- A aplicação WordPress deve estar acessível através das portas 80 ou 8080.
- Utilize um repositório Git para versionamento do código.



## Alteração da Arquitetura: Bastion Host para EC2 Instance Connect Endpoint

Originalmente, a arquitetura planejada incluía um bastion host para acesso seguro às instâncias EC2. No entanto, para aumentar a segurança e simplificar o gerenciamento, a arquitetura foi modificada para usar o EC2 Instance Connect Endpoint. Isso permite o acesso SSH às instâncias EC2 sem a necessidade de gerenciar um bastion host separado.

Exemplo de um ambiente com EC2 Instance Connect Endpoint:


![image](https://github.com/Tri3010/CompasspbDocker/assets/94199408/7aa6cfbd-3428-4a7a-9249-6c3612948c5e)


## Configuração do Ambiente:
1- Criar VPC:
- Abra o console da Amazon VPC 
- No painel da VPC, escolha Criar VPC e muito mais.
    - VPC: VPC_pb_docker-vpc
    - CIDR IPv4: 10.0.0.0/16
    - Zonas de Disponibilidade (AZ): 2
    - Sub-nets Publicas:2
    - Sub-nets Privadas:2 
    - Gateway NAT: VPC_pb_docker-nat-public1-us-east-1a
    - Configurado tabelas de rotas para NAT Gateway
 
    - Mapa da VPC:
 
      -![Mapa VPC](https://github.com/Tri3010/CompasspbDocker/assets/94199408/d711579e-a555-4204-a557-bcd8104dd94a)


2 - Criar Grupos de Segurança para os recursos a serem usados

  - EC2-WebServerWP - Inbound Rules
   
| Type  |	Protocol |	Port Range	|    Source   |
| :---: |   :---:    |    :---:     |   :---:     |
|  SSH  |   TCP      |	   22       |	SG-EC2-ICE |
| HTTP  |	TCP	   |    80	      |   SG-LB     |


  - EC2-ICE - Outbound Rules
   
| Type  |	Protocol |	Port Range	|      Source         |
| :---: |   :---:    |    :---:     |     :---:           |
|  SSH  |   TCP      |	   22       |	SG-EC2-WebServerWP |


  - EFS - Inbound Rules
   
| Type  |	Protocol |	Port Range	|      Source         |
| :---: |   :---:    |    :---:     |     :---:           |
|  NFS  |   TCP      |	   2049     |	SG-EC2-WebServerWP |


  - RDS - Inbound Rules
   
|     Type       |	Protocol |	Port Range	|      Source         |
|     :---:      |   :---:    |    :---:     |     :---:           |
|  MYSQL/Aurora  |    TCP     |	   3306     |	SG-EC2-WebServerWP |


 - Load Balancer - Inbound Rules
   
|     Type       |	Protocol |	Port Range	|      Source         |
|     :---:      |   :---:    |    :---:     |     :---:           |
|      HTTP      |    TCP     |	    80      |	  0.0.0.0/0        |



3- Criado EFS: EFS_pb_docker
   - Destinos de montagem: sub-nets privadas

     EFS com os destinos de montagem:

     ![EFS](https://github.com/Tri3010/CompasspbDocker/assets/94199408/d1f3d81d-2abf-4f9e-92e2-32ccc4139052)


4- Criado RDS: 
   - MySQL 8.0.3
   - Identificador da Instância: rdswp
   - Nome do usuário: admin
   - Configurei as senhas
   - Configuração e Armazenamento da Instância ficaram padrão
   - Conectividade: Não se conectar a um recurso de computação do EC2 manualmente mais tarde.
   - Nuvem privada virtual (VPC): VPC_pb_docker-vpc
   - Grupo de sub-redes: Default (todas)
   - Acesso Público: Não
   - Grupo de Segurança: SG-RDS
   - Autenticação de Banco de Dados: Autenticação de senha
   - Configuração Adicional:
     - Nome do banco de dados inicial: db_wordpress
     - Restante deixado padrão
     - Selecionado Criar Banco de Dados
     

   - Detalhes RDS

     - ![RDS 2](https://github.com/Tri3010/CompasspbDocker/assets/94199408/b8b9c705-b850-4e1d-9099-99ef630b5357)


5- Criado Par de Chaves:
- No console do EC2;
- Selecionei "Pares de Chaves" no painel de navegação;
- Escolhi "Criar Pares de chaves";
- Coloquei um "Name";
- Tipo de par de chaves foi RSA;
- Formato de arquivo foi Pem;
- Criado o par de chaves;

- O arquivo de chave privada é baixado automaticamente pelo navegador. Arquivo salvo em local seguro.

6- Criado Instância EC2 para testes:
   - Adicionado Tags necessárias
   - AMI: Amazon Linux 2
   - Tipo: t3 small
   - Adicionada minha key pair
   - Rede: sub-net privada 1a
   - Grupo de segurança: SG-EC2-WebServerWP
   - Volume raiz: 16 GiB -gp2
   - Detalhes avançados - inserido script [user_data.sh](https://github.com/Tri3010/CompasspbDocker/blob/main/user_data.sh) necessário para instalação via script de Start Instance.
* Testes iniciais do projeto realizados com essa instância. Ao final dessa etapa a instância foi encerrada.
  
7- Criado EC2 Instance Connect Endpoint:
   - No console da VPC -> Endpoints -> Criar novo endpoint
   - Nome: EC2-ICE
   - Categoria de serviço: Endpoint do EC2 Instance Connect
   - Selecionar VPC
   - Escolher Security Group: SG-EC2-ICE
   - Seleciona Criar Endpoint.

8- Criado Load Balancer:
   - Nome: LBWordPress
   - Voltado para Internet
   - Seleciona VPC
   - Mapeamento: as duas sub-nets publicas
   - Grupo de Segurança: Criado para ele
   - Verificações de integridade: HTTP:80 /wp-admin/install.php
   - Seleciona Criar Balanceador de carga
   
   
9- Criado Modelo de execução EC2:
   - Nome: TemplateWebServer
   - Selecionado: Fornecer orientação para me ajudar a configurar um modelo que eu possa usar com o Auto Scaling do EC2
   - AMI: Amazon Linux 2
   - Tipo: t3 small
   - Adicionada minha key pair
   - Configuração de Rede: Não incluir no modelo de Execução.
   - Grupo de segurança: SG-EC2-WebServerWP
   - Adicionado Tags necessárias
   - Detalhes avançados - inserido script [user_data.sh](https://github.com/Tri3010/CompasspbDocker/blob/main/user_data.sh) necessário para instalação via script de Start Instance.

10- Criado Auto Scalling Group:
   - Nome: ASGwordpress
   - Escolha do Modelo de Execução: TemplateWebServer
   - Versão do Modelo de Execução: Default (1)
   - Rede:
     - VPC: VPC_pb_docker-vpc
     - Zonas de disponibilidade e sub-redes: Selecionada asduas sub-redes privadas.
   - Balanceamento de Carga:
     - Anexar a um balanceador de carga existente
     - Escolher entre Classic Load Balancers: LBWordPress
   - Tamanho do grupo:
     - Capacidade desejada: 2
     - Capacidade mínima: 2
     - Capacidade máxima: 4
   - Revisado
   - Selecionado Criar Grupo de Auto Scalling

11- Instalação WordPress:
  - Copiado DNS do Load Balancer no navegador
  - Pagina de Idioma: Português (Brasil)
  - Colocado dados do usuário
  - Install WordPress
  - Testando:
     - Pagina padrão do WordPress acessada corretamente.

       ![Captura de Tela (10)](https://github.com/Tri3010/CompasspbDocker/assets/94199408/7337d7ba-a12e-4dd4-b588-9544f4c80f41)






