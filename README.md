# teste-neoway
Código utilizado para prover a infraestrutura como definido no teste

Foi utilizado terraform versão 0.12

## Infraestrutura

O projeto consiste de um Cluster ECS rodando um Service com a imagem docker com a aplicação da empresa cliente (https://hub.docker.com/r/jwilder/whoami)

A aplicação é executada em duas instancias EC2 em um autoscaling group e pode ser acessada pela url do load balancer.

O autoscaling group define que nos horarios entre 7:00h e 19:00h devem haver duas instancias rodando, fora desse horario devem haver 0.

Para acessar as instancias via ssh é necessario primeiramente acessar o bastion host, uma instancia EC2 com um ip público.

A partir do bastion host é possível acessar as instancias rodando a aplicação por meio de ssh utilizando seus respectivos ips privados.

Para visualizar informações de monitoramento, deve-se acessar o painel do AWS CloudWatch. Não foi implementada nenhuma solução personalizada.

## Configuração

É necessário criar um perfil `terraform` nas credenciais da AWS em `~/.aws/credentials`

```
[terraform]
aws_access_key_id = <AWS_KEY_ID>
aws_secret_access_key = <AWS_SECRET_KEY>
```

Também é necessário gerar um par de chaves ssh para cadastrar o par de chaves na AWS

```
ssh-keygen -m PEM
```

## Construindo a Infraestrutura

Para construir a infraestrutura basta executar os seguintes comandos

```
terraform init
terraform plan -var "public_key_path=<Caminho/para/sua/chave/publica.pub>" -out tfplan
terraform apply tfplan
```

Ao fim da execução será exibido o nome dns da aplicação e o ip do bastion host

```
app_dns_name = dominio-da-aplicacao.com
bastion_host_public_ip = 22.2.2.2
```

## Destruindo a infraestrutura

Para desfazer todas as alterações execute o seguinte comando:

```
terraform destroy -var "public_key_path=<Caminho/para/sua/chave/publica.pub>"
```

Digite "yes" para remover todos os recursos criados.

## Acessando as instancias da rede privada por ssh

É necessário anexar a autenticação ao fazer ssh no bastion host

```
ssh-add -k <chave_ssh_privada>
ssh -A ec2-user@<ip_do_bastion_host>
[ec2-user@ip] ssh ec2-user@<ip_privado_da_instancia_ec2>
```
