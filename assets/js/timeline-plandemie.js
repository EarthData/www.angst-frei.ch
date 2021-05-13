json_template = '/json/timeline-plandemie.json'
var options = {
  language: "de",
  width: "100%",
  height: "100%",
  initial_zoom: 3,
  slide_padding_lr: 100,
  hash_bookmark: true,
  start_at_end: false,
}
window.timeline = new TL.Timeline('timeline-embed', json_template, options);
