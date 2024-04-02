# CompasspbDocker
Repositório criado para atividade Docker do Programa de Bolsas Compass DevSecOps 2024

Este projeto visa facilitar a instalação e configuração de um ambiente WordPress na AWS, utilizando Docker ou Containerd como runtime de contêineres. O objetivo é fornecer uma solução escalável e altamente disponível, integrando serviços como Amazon RDS, Amazon EFS e AWS Load Balancer.

## Pré-requisitos

Antes de começar, é necessário garantir que você tenha:

- Uma conta na AWS com permissões para criar e gerenciar recursos.
- Acesso à AWS CLI ou ao console da AWS.
- Conhecimento básico de Docker e AWS.

## Instruções

1. **Instalação e Configuração do Docker ou Containerd no host EC2:**
   - Crie uma instância EC2 na AWS.
   - Utilize o script de inicialização (user_data.sh) para instalar e configurar o Docker ou Containerd na instância EC2.
   - Certifique-se de que a instância tenha conectividade com a internet para baixar os pacotes necessários.

2. **Deploy da Aplicação WordPress:**
   - Configure um banco de dados MySQL no Amazon RDS.
   - Crie um contêiner de aplicação WordPress.
   - Conecte a aplicação WordPress ao banco de dados MySQL.



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
- No painel da VPC, escolha Criar VPC.
    Criada VPC com:
      2 Zonas de Disponibilidade;
      2 Subnets Publicas e 2 Subneta Privadas
      1 Gateway NAT

2- Configurado NAT Gateway com Tabelas de Rotas

3- # Criar/editar Grupos de Segurança#
4- # Criar ec2 instance connect endpoint:#
5- # Criar EFS:#
6- # Criar RDS:#
7- # Criar Load Balancer:#
8- # Criar Modelo de execução EC2#








