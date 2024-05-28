# cicd-php

# use
```shell
docker push vadik/php-deployer
# or
docker push vadik/php-deployer:8.1-fpm-node22
```

# example local build
```shell
docker build -t php-deployer .
# or
docker build -t php-deployer . --progress plain
# run
docker run -it --rm php-deployer bash
```