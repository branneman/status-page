# status-page

Communicate service status to your users via a web page.

## Run

Install [Racket](https://racket-lang.org/). Clone git repo. Install dependencies. Run tests.

```sh
git clone git@github.com:branneman/status-page.git
cd status-page
raco pkg install --deps search-auto
raco test -qx .
```

Run app:

```sh
export TOKEN=secret
racket main.rkt
```

## How to use & customise

You probably want to write custom topics which collect the status of service components you value.
Topics are located in `src/topics/`, they are updated on interval from `src/topics/index.rkt`.
Any `*.json` file located in the `data/topics/` directory will be loaded during html generation,
you could even have another program automatically update files in there.

Next, you'll want to customise the UX to match your company/service:

- HTML template file: `src/status-page/html.tpl.rkt`  
  (this template compiles on interval and then overwrites `htdocs/index.html`)
- Statics, like CSS and favicon: `htdocs/static/*` and `htdocs/favicon.ico`
- Error pages: `htdocs/404.html` and `htdocs/500.html`

## Docker: build & run

```sh
docker build -t status-page .
docker run -d -t -p 8000:8000 status-page
```

## How to override status

Create a markdown document with a short message, e.g. `status-page-override.md`:

```md
## Update 2021-08-01 13:37 UTC:
We've received reports of degraded performance on the GraphQL API. We are investigating.
```

Post that markdown document to `/api` (substituting your token):

```sh
export TOKEN=secret
curl -f http://localhost:8000/api \
  -X POST \
  -H "authorization: Bearer $TOKEN" \
  -H "content-type: text/markdown; charset=utf-8" \
  --data-binary "@status-page-override.md"
```

To remove the status override, just update to an empty document: `--data-binary ""`

## Architecture

This is a tiny and very extensible application written in Racket. It periodically determines the
status for different components of your service (called 'topics'), and acts as web server conveying
that status in a user-friendly way.

![status-page-architecture](https://user-images.githubusercontent.com/172579/121574017-64d90400-ca15-11eb-8447-98557939ba6b.png)

## Todo

- [feature] Load any `*.json` file located in the `data/topics/` directory during `(topics-update-all!)`
- [feature] Move to last-updated datetime per topic
- [feature] Load settings via environment (e.g. [dotenv](https://docs.racket-lang.org/dotenv/))
- [feature] Implement DNS and TLS topic
- [feature] Implement Backup via S3: `backup-restore` and `backup-now`
- [tech debt] Consider removing `html-template` dependency, can this be done with xml or sxml?
- [tech debt] Web-server: Refactor from custom dispatcher to idiomatic dispatcher
- [tech debt] Logging in standardised format
- [tech debt] Unit tests
