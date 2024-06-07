> [!TIP]
> Possibly: [misskey-dev/Misskey](https://github.com/misskey-dev/misskey)

![](misskey-logo.png)

# Misskey

[Misskey](https://misskey.xyz/) is a mysterious Twitter-style SNS.
It runs on Node.js.

## Related Projects
* [syuilo/Misskey-Image](https://github.com/syuilo/Misskey-Image) - Misskey image server

## API
Misskey provides web-based API.
See [API documentation](doc/api.md).

## Special thanks
古谷向日葵, 大室櫻子 (2014 June ~)

## License
[The MIT License](LICENSE)

## About Misskey.old-Fix
> [!CAUTION]
> Misskey.old is not supported ActivityPub and has not been maintained for a long time, so bugs and security flaws may exist. Do not use it in a production environment.

Misskey.old-Fix is a modified version of Misskey.old forked to run the environment of the time of Misskey.old on the latest Node.js as much as possible.

Also, since the reason for creating this fork is to be able to actually build the environment that existed at the time of misskey.xyz, we have kept updates to the minimum necessary and will not fix bugs except for those that affect the operation, such as misskey.old not starting. If you want to build Misskey on the assumption that you will actually publish your server, please use the [latest version](https://misskey-hub.net/en/docs/for-admin/install/guides/).
### Difference of Misskey (latest)
- Misskey.old is not supported ActivityPub
  - Misskey.old does not support ActivityPub because Misskey implemented ActivityPub support around 2018.
- The domain of the instance is hard-coded
  - This is probably because it is designed to operate on misskey.xyz.
