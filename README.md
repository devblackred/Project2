## ATIVIDADE AWS_DOCKER

Este guia prático te ensina a construir a criar uma aplicação WordPress na AWS, utilizando Docker, EFS e Load Balancer. 

### Por que essa solução é tão poderosa?

* **Docker:** Empacota e isola o WordPress e o MySQL em contêineres, garantindo portabilidade e fácil gerenciamento.
* **EFS (Elastic File System):** Armazena os arquivos do seu blog de forma persistente e compartilhada, evitando perda de dados e simplificando o escalonamento.
* **Load Balancer:** Distribui o tráfego entre instâncias do WordPress, garantindo alta disponibilidade e tolerância a falhas.

### Pré-requisitos:

* Uma conta na AWS
* Conhecimento básico de EC2, VPC, EFS e Load Balancer
* Familiaridade com Docker e Docker Compose

### Arquitetura da Solução:

1. **Instância EC2:** Abriga e executa os contêineres Docker do WordPress e MySQL.
2. **EFS:** Funciona como um disco rígido virtual compartilhado, armazenando os arquivos do WordPress de forma segura e persistente.
3. **Load Balancer:**  Distribui o tráfego para as instâncias EC2, garantindo que o blog permaneça online mesmo em caso de falha de uma instância.

### Mãos à obra!

**Fase 1: Preparando o Terreno - Configurando a Instância EC2**

1. No console do EC2, clique em "Launch Instance".
2. Selecione a AMAZON Linux 2 AMI.
3. Escolha o tipo de instância "t3.small".
4. Em "Configure Instance Details", expanda "Advanced Details" e cole o script fornecido no campo "User data". Este script:
    * Atualiza os pacotes do sistema
    * Instala o Docker e o Docker Compose
    * Instala o cliente NFS para o EFS
    * Cria um diretório para montar o EFS
    * Reinicia o serviço do Docker
5. Ao criar a instância, assegure-se de:
    * Criar ou selecionar um par de chaves SSH.
    * Abrir as portas 80 e 443 no grupo de segurança para o tráfego HTTP e HTTPS.
6. Conecte-se à sua instância EC2 via SSH.

**Fase 2: Criando um Sistema de Arquivos Eterno com o EFS**

1. Acesse o console do EFS e clique em "Create file system".
2. Dê um nome ao sistema de arquivos.
3. Selecione a VPC e a subnet onde a instância EC2 está localizada.
4. Escolha "General Purpose" como "Performance mode" e mantenha as configurações padrão.
5. Clique em "Create" e anote o "File system ID" - você precisará dele mais tarde!

**Fase 3: Conectando o EFS à sua Instância EC2**

1. Conecte-se à sua instância EC2 via SSH.
2. Execute o comando fornecido, substituindo  `file-system-id` pelo ID do seu EFS e `region` pela região da sua AWS:

   ```bash
   sudo mount -t nfs -o vers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-xxxxxxxxxxxxxxxxx.efs.us-east-1.amazonaws.com:/ /efs/wordpress
   ```

3. Para tornar a montagem permanente, adicione a linha fornecida ao arquivo `/etc/fstab`, substituindo os valores conforme necessário:

   ```
   fs-xxxxxxxxxxxxxxxxx.efs.us-east-1.amazonaws.com:/ /efs/wordpress nfs defaults,_netdev 0 0
   ```

**Fase 4: Definindo as Peças do Quebra-cabeça - O Arquivo docker-compose.yml**

1. Crie um arquivo chamado `docker-compose.yml` na sua instância EC2:

   ```yaml
   version: '3'
   services:
     db:
       image: mysql:8.0
       restart: always
       environment:
         MYSQL_ROOT_PASSWORD: 'sua_senha_forte'
         MYSQL_DATABASE: wordpress
         MYSQL_USER: wordpress
         MYSQL_PASSWORD: 'sua_senha_forte'
       volumes:
         - db_data:/var/lib/mysql
     wordpress:
       depends_on:
         - db
       image: wordpress:latest
       restart: always
       ports:
         - "80:80"
       environment:
         WORDPRESS_DB_HOST: db
         WORDPRESS_DB_USER: wordpress
         WORDPRESS_DB_PASSWORD: 'sua_senha_forte'
         WORDPRESS_DB_NAME: wordpress
       volumes:
         - wordpress_data:/var/lib/wordpress
   volumes:
     db_data:
       driver: local
     wordpress_data:
       driver: local
       driver_opts:
         type: none
         o: bind
         device: /efs/wordpress
   ```

**Fase 5: Subindo a Aplicação WordPress**

1. Navegue até o diretório do arquivo `docker-compose.yml`.
2. Execute o comando:

   ```bash
   sudo docker-compose up -d
   ```

**Fase 6: - Configurando o Load Balancer**

1. No console do EC2, vá em "Load Balancers" na seção "Load Balancing".
2. Clique em "Create Load Balancer" e escolha "Application Load Balancer".
3. Dê um nome ao Load Balancer.
4. Em "Scheme", selecione "Internet-facing".
5. Em "IP address type", selecione "IPv4".
6. Escolha a VPC da sua instância EC2.
7. Crie um novo grupo de segurança ou use um existente que permita tráfego HTTP (porta 80).
8. Clique em "Next: Configure Security Groups" e depois em "Next: Configure Routing".
9. Em "Target group", selecione "New target group".
10. Dê um nome ao Target Group.
11. Em "Protocol", selecione "HTTP".
12. Em "Port", digite "80".
13. Em "Health checks", defina "Protocol" como "HTTP", "Path" como "/" e mantenha as outras configurações.
14. Clique em "Next: Register targets".
15. Selecione a instância EC2 e clique em "Add to registered".
16. Clique em "Next: Review" e depois em "Create target group".
17. Volte à configuração do Load Balancer e selecione o Target Group criado.
18. Clique em "Next: Review" e depois em "Create load balancer".

**Fase 7: Finalizando a Configuração do WordPress**

1. Acesse o endereço DNS do Load Balancer em um navegador. Você verá a página de configuração do WordPress!
2. Siga as instruções, criando um usuário e senha de administrador.

**Fase 8: Verificando a Instalação**

1. Acesse seu blog usando o endereço DNS do Load Balancer.
2. Faça login no painel de administração do WordPress.
3. Crie páginas, publique posts e faça upload de arquivos de mídia para testar

**Parabéns!** Seu WordPress agora está pronto, com alta disponibilidade e sem medo de perder dados!

## Leitura Complementar:

* **Segurança:** Configure um certificado SSL/TLS para o seu Load Balancer e proteja o tráfego.
* **Backup:** Configure backups regulares para o EFS e tenha ainda mais segurança para seus dados.
* **Escalabilidade:** Para lidar com o aumento do tráfego, configure o Auto Scaling para sua aplicação.
