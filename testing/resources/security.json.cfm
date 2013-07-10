[
    {
        "whitelist": "user\\.login,user\\.logout,^main.*",
        "securelist": "^user\\.*, ^admin",
        "match": "event",
        "roles": "admin",
        "permissions": "",
        "redirect": "user.login",
        "useSSL": false
    },
    {
        "whitelist": "",
        "securelist": "^shopping",
        "match": "url",
        "roles": "",
        "permissions": "shop,checkout",
        "redirect": "user.login",
        "useSSL": true
    }
]