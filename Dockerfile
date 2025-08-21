# Estágio 1: Build - Usa uma imagem com o JDK completo para compilar o projeto
FROM maven:3.8.5-openjdk-17 AS build

# Define o diretório de trabalho dentro do contêiner
WORKDIR /app

# Copia o pom.xml e os arquivos do maven wrapper primeiro para aproveitar o cache do Docker
COPY .mvn/ .mvn
COPY mvnw pom.xml ./

# Baixa as dependências do projeto
RUN mvn dependency:go-offline

# Copia o resto do código-fonte da aplicação
COPY src ./src

# Compila a aplicação e gera o arquivo .jar, pulando os testes
RUN mvn package -DskipTests


# Estágio 2: Run - Usa uma imagem leve, apenas com o Java Runtime, para rodar a aplicação
FROM openjdk:17-jdk-slim

# Define o diretório de trabalho
WORKDIR /app

# Copia o arquivo .jar gerado no estágio de build para a imagem final
COPY --from=build /app/target/dslist-0.0.1-SNAPSHOT.jar app.jar

# Expõe a porta em que a aplicação Spring roda (padrão é 8080)
EXPOSE 8080

# Comando para iniciar a aplicação quando o contêiner for executado
ENTRYPOINT ["java", "-jar", "app.jar"]
