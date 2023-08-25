{ _utils, ... }:

{
  services.nitter = {
    enable = true;
    redisCreateLocally = false;  # why is the default of this `true`??
    server = {
      title = "NSM";
      port = 36325;
      https = true;
      hostname = "nitter.soopy.moe";
      address = "127.0.0.1";
    };
  };

  systemd.services.nitter = {
    environment = {
      NITTER_ACCOUNTS_FILE = "/etc/nitter/guest_accounts.json";
    };
  };

  services.nginx.virtualHosts."nitter.soopy.moe" = _utils.mkSimpleProxy {
    port = 36325;
  };
}
