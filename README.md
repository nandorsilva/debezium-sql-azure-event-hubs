# Debezium SQL Server com Azure Event-hubs

O Debezium é uma plataforma opensource de captura de dados alterados utilizando como tecnologia Change Data Capture (CDC), que atinge suas qualidades de durabilidade, confiabilidade e tolerância a falhas reutilizando o Kafka e o Kafka Connect.

A utilização do CDC para os aplicativos nos dias de hoje, é quase que um cenário obrigatório. Como para realização de análise de dados em tempo real, comunicação entre aplicações utilizando arquitetura de event-driven.

Hubs de Eventos é um serviço PaaS da Microsoft Azure para ingestão de dados em tempo real totalmente gerenciado, simples e escalável. Transmite milhões de eventos por segundo.
Os dados enviados para um hub de eventos podem ser transformados e armazenados usando qualquer provedor de análise em tempo real ou adaptadores de envio em lote/armazenamento.

Para esse exemplo iremos utilizado a captura dos dados em Sql Server utilizando o Debezium e enviado para o Hub de eventos na Cloud, utilizando Docker.

![Arquitetura](https://raw.githubusercontent.com/nandorsilva/debezium-sql-azure-event-hubs/master/doc/arquitetura.png "Arquitetura")

### Event-Hub

No portal da azure consulte a opção event bus.

![](https://raw.githubusercontent.com/nandorsilva/debezium-sql-azure-event-hubs/master/doc/event-bus-1.png)

![](https://raw.githubusercontent.com/nandorsilva/debezium-sql-azure-event-hubs/master/doc/event-bus-2.png)

> Nota: O Pricing tier precisa ser Standard, somente a opção Standard e Dedicated tem suporta para a utilização do Kafka.

### Subindo os containers

Para nosso tutorial utilizo os contêineres das imagens sql server da Microsoft e para o conector do debezium, conforme arquivo docker-compose.yaml

### Registrando as variáveis de ambiente.

O Docker Compose utilizara as variáveis de ambiente abaixo:

```bash
export DEBEZIUM_VERSION=1.1
export EH_NAME=pocevento
export EH_CONNECTION_STRING="Endpoint=sb://pocevento.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=hXWVP8Bbmx1g3hJH2SYlazVF6wlIfR2dm1oy4t/+V+Y="
```

> Os dados das variáveis EH_NAME e EH_CONNECTION_STRING estão no hub de eventos:

![](https://raw.githubusercontent.com/nandorsilva/debezium-sql-azure-event-hubs/master/doc/event-bus-3.png)

![](https://raw.githubusercontent.com/nandorsilva/debezium-sql-azure-event-hubs/master/doc/event-bus-4.png)

O Debezium precisa do Apache Kafka para executar, o EventHubs expõe conexão compatível com Kafka, para que ainda possamos desfrutar do Kafka com todo o conforto de uma oferta PaaS.

Antes de mais, o EventHubs requer autenticação:

```yaml
- CONNECT_SECURITY_PROTOCOL=SASL_SSL
- CONNECT_SASL_MECHANISM=PLAIN
- CONNECT_SASL_JAAS_CONFIG
```

Outras opções úteis para executar o Debezium no EventHubs são as seguintes:

```yaml
- CONNECT_KEY_CONVERTER_SCHEMAS_ENABLE = false
- CONNECT_VALUE_CONVERTER_SCHEMAS_ENABLE = true
```

Eles controlam se o esquema é enviado com os dados ou não. Como o EventHub suporta apenas valores, ao contrário do Apache Kafka, que na verdade é um par de valores-chave, a geração do esquema para a seção de chaves pode ser desativada com segurança.

Para saber mais sobre as configurações do event hus e conectores

[Para saber mais sobre as configurações do event hus e conectores](https://github.com/debezium/docker-images/tree/master/connect-base/0.10#others)

A segurança dos EventHubs usa a cadeia `$ConnectionString` como nome de usuário. Para evitar que o Docker Compose o trate como uma variável, por ter somente um cifrão é necessário usar ele duas vezes (`$$`).

```shell
docker-compose -f docker-compose.yaml up
```

Se tudo estiver dado certo até aqui, veremos os containers abaixo:

```shell
docker container ls
```

![](https://raw.githubusercontent.com/nandorsilva/debezium-sql-azure-event-hubs/master/doc/event-bus-6.png)

### Sql Server

Para esse tutorial estou utilizando a imagem sql server da Microsoft `microsoft/mssql-server-linux`

Para criar a estrutura dos dados estou utilizando o proprio container criado.

```shell
cat sql/init.sql | docker exec -i debezium-sql-azure-event-hubs_sqlserver_1 bash -c '/opt/mssql-tools/bin/sqlcmd -U sa -P $SA_PASSWORD'
```

### Criando o conector

```shell
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @debezium/register-debezium.json
```

Após a criação do conector vamos criar um registro no banco de dados e ver o tópico sendo criado no event-bus

```shell
INSERT INTO produtos(nome,descricao)  VALUES ('Celular','Celular novo);
```

![](https://raw.githubusercontent.com/nandorsilva/debezium-sql-azure-event-hubs/master/doc/event-bus-5.png)

[Para mais informações sobre debezium](https://debezium.io/)
