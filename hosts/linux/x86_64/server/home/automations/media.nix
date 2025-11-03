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
      title = "new media";
      message = ''
        {% if trigger.json.get('ItemType') == 'Episode' and trigger.json.get('SeriesName') %}
        {{ trigger.json.SeriesName }}{% if trigger.json.get('SeasonNumber00') and trigger.json.get('EpisodeNumber00') %} - S{{ trigger.json.SeasonNumber00 }}E{{ trigger.json.EpisodeNumber00 }}{% endif %}{% if trigger.json.get('Name') %}: {{ trigger.json.Name }}{% endif %}
        {% elif trigger.json.get('ItemType') == 'Movie' %}
        {{ trigger.json.get('Name', 'Unknown') }}{% if trigger.json.get('Year') %} ({{ trigger.json.Year }}){% endif %}
        {% elif trigger.json.get('ItemType') == 'Book' %}
        {{ trigger.json.get('Name', 'Unknown') }}{% if trigger.json.get('Year') %} ({{ trigger.json.Year }}){% endif %}
        {% elif trigger.json.get('ItemType') == 'Audio' %}
        {{ trigger.json.get('Name', 'Unknown') }}{% if trigger.json.get('Album') %} - {{ trigger.json.Album }}{% endif %}
        {% else %}
        {{ trigger.json.get('Name', 'Unknown') }}
        {% endif %}
      '';
      data = {
        image = "{{ trigger.json.get('ImageUrl', '') }}";
      };
    };
  }];
}
