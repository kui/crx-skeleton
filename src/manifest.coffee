name: "TODO write a name"
version: "0.0.1"
description: "TODO write a description"
content_scripts: [
  matches: [ "<all_urls>" ]
  js: [ "foo.js" ]
  run_at: "document_end"
]
manifest_version: 2
