# Deployment

Repo for deployment related stuff. Also a way of managing services on 1 server. Since it's not going to scale that much it makes sense to deploy this all at once.

**Some Makefile commands maky only apply for Ubuntu and Ubuntu-based distributions. And obiviously no Windows or MacOS support**

## VPS all in one deploy

**Consider setting up [PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) before cloning**

1. `git clone https://oauth:{TOKEN with repo and read:org scopes}@github.com/sora-reader/deployment`
2. `cd deployment`
3. `make dotenv # setup dotenvs`
4. `make create-user`
5. `make clone`
6. `make dotenv-other # and setup new dotenvs`
7. `make deploy`

