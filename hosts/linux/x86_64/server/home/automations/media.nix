{ ... }: {
  alias = "notify of new media";
  trigger = [{
    platform = "webhook";
    webhook_id = "media";
    allowed_methods = [ "POST" ];
    local_only = true;
  }];
  action = [{
    service = "notify.phones";
    data = {
      title = "{{ trigger.json.title }}";
      message = "{{ trigger.json.message }}";
    };
  }];
}
