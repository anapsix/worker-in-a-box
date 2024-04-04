# worker-in-a-box

NOTE: please see Cloudflare's official [`workerd`][cf-workerd] for running
Cloudflare Workers in local dev environment.

[Cloudflare Workers][cf-workers] are awesome! But what if you want to run
workers in your dev environment, or in your own environment? Well, there is
a great project (albeit, unmaintained) from Dollar Shave Club - [cloudworker],
which allows you to run Cloudflare Workers locally. Let's combine it with
[Nginx Unit][nginx-unit], and run it in a Docker container.

Using an image built based on this repo as source in `FROM` directive, one can
create a functional worker-in-a-box.


## Usage

1. Initialize submodule
```bash
git submodule init
git submodule update
```

2. Build worker-in-a-box image
```bash
docker build -t worker .
```

3. Use the image to package your Cloudflare Worker (see [hello-world] example)
```Dockerfile
# Dockerfile
FROM worker
```
```bash
docker build -t hello-world .
```

4. Launch it
```bash
docker run -it --rm -p 8080:8080 hello-world
```

5. Access it via http://localhost:8080


## TODO
- patch [cloudworker] to support Redis as KV
- improve `lauch_worker.js` script to work with KV bindings
- improve ONBUILD process

[link reference]::
[cf-workerd]: https://github.com/cloudflare/workerd 
[cf-workers]: https://workers.cloudflare.com/
[cloudworker]: https://github.com/dollarshaveclub/cloudworker
[nginx-unit]: https://unit.nginx.org/
[hello-world]: ./examples/hello-world
