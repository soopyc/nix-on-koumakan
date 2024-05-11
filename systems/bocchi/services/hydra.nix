{
  _utils,
  config,
  ...
}: let
  secrets = _utils.setupSecrets config {
    namespace = "hydra";
    secrets = [
      "signing_key"
      "auth/gitea/cassie"
    ];
    config = {
      owner = config.users.users.hydra-www.name;
      group = config.users.users.hydra-www.group;
      mode = "0440";
    };
  };
in {
  imports = [
    secrets.generate

    (secrets.mkTemplate "hydra-auth.conf" ''
      <gitea_authorization>
        cassie = ${secrets.placeholder "auth/gitea/cassie"}
      </gitea_authorization>
    '')
  ];

  services.hydra = {
    enable = true;
    listenHost = "127.0.0.1";
    useSubstitutes = true;
    hydraURL = "https://hydra.soopy.moe";
    notificationSender = "hydra@services.soopy.moe";
    smtpHost = "mail.soopy.moe";

    extraConfig = ''
      compress_build_logs 1
      binary_cache_secret_key_file ${secrets.get "signing_key"}

      <git-input>
        timeout = 1800
      </git-input>

      # Includes
      Include ${secrets.getTemplate "hydra-auth.conf"}
    '';

  };

  services.nginx.virtualHosts."hydra.soopy.moe" = _utils.mkSimpleProxy {
    port = 3000;
    extraConfig = {
      useACMEHost = "bocchi.c.soopy.moe";
    };
  };
}
