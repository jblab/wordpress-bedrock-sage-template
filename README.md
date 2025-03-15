# Bedrock + Sage Template <img src="https://assets.jblab.info/2024/03/17/jblab-logo-with-text.26da23672fc44c17078dc8ce2ff8495ddb190163.webp" alt="jblab logo" width="120" align="right" style="max-width: 100%">

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=flat-square)](LICENSE)

This repository serves as a foundational template for building WordPress-based websites using **Bedrock** for better
structure and dependency management and **Sage** for a modern, streamlined theme development experience. The project is
preconfigured with **Docker** for efficient local development and leverages a **dockerized FrankenPHP** setup, combining
PHP processing and web server functionality for seamless performance and deployment.

## Key Features:

- **Modern WordPress Stack**: Powered by Bedrock for enhanced security and organization.
- **Advanced Theme Development**: Utilizes Sage for cutting-edge theming tools and workflows.
- **Dockerized Development**: Simplified local setup using Docker, ensuring consistency across environments.
- **FrankenPHP Integration**: A lightweight PHP/webserver production-ready container designed for modern PHP
  applications.

## Installation

> [!NOTE]
>
> When using the Docker environment as-is, it expects `local.julienbonnier.dev` as the local URL and requires a valid
> TLS certificate. By default, Docker will search for the certificate at `~/.tls/local-dev/server.crt` and its
> corresponding key at `~/.tls/local-dev/server.key`, where `~` represents your home directory.
>
> All of these settings can be modified in the `compose.override.yaml` file.

Follow these steps to install and set up the project:

1. Make sure you have a `.env` file in `src/`:
   ```shell
   cp src/.env.example src/.env
   ```
   or:
   ```shell
   touch src/.env
   ```
2. Start the project locally:
   ```shell
   docker compose up -d 
   ```
3. Install Dependencies:
   ```shell
   docker compose exec php-cli composer install
   ```
4. Install the theme's Dependencies:
   ```shell
   docker compose exec php-cli composer install --working-dir ./web/app/themes/sage
   ```

> [!TIP]
>
> This project includes a Makefile to simplify common tasks.
>
> Run the following to see all available options:
> ```shell
> make help
> ```

## Contributing

We love contributions! If you have an idea for a feature, feel free to open an issue or, better yet, submit a pull request. We welcome participation, whether you're submitting code, reporting bugs, or asking questions.
Check out the [contribution guidelines](CONTRIBUTING.md) to get started.

## License

This bundle is released under the [Apache 2.0 License](LICENSE). Feel free to use it in your projects.
