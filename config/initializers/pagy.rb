require "pagy/extras/headers"
require "pagy/extras/metadata"

Pagy::DEFAULT[:headers] = {
  page:  "Current-Page",
  limit: "Page-Items",
  count: "Total-Count",
  pages: "Total-Pages"
}
