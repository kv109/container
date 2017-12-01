## Setup for development

#### Requirements

```bash
ruby -v && docker -v && docker-compose -v && echo "You're all set :)"
```

#### Create your .env files

See
- `postgres/.env.example`
- `web/.env.example`

#### Download git submodule for web application

```bash
git submodule update --init --recursive
```

#### Build image for web application

```bash
cd web
./build_image.rb
```

#### Build image for web postgres

```bash
cd postgres
./build_image.rb
```

#### Start application

```bash
docker-compose up web
```

For more output, run (in another tab):
```bash
docker-compose logs --follow
```

**Note**: During the first time it can take a while, since it will download postgres dump from S3. What will be in the dump? Well, it's complicated, better ask somebody ;)

## Deploy on staging (wip)

#### Setup awscli

1. [Install](http://docs.aws.amazon.com/cli/latest/userguide/installing.html) `awscli`.
2. Run
```bash
aws configure
```
and enter your credentials.

#### Push image with web application to aws

```bash
cd web
./build_image.rb --push=staging
```

See `./build_image.rb --help` for more details.
