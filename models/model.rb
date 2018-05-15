class EllieShopifyOrder < ActiveRecord::Base
    self.table_name = "ellie_shopify_orders"
end

class MarikaShopifyOrder < ActiveRecord::Base
    self.table_name = "marika_shopify_orders"
end

class EllieCollect < ActiveRecord::Base
    self.table_name = "ellie_collects"
end

class EllieCustomCollection < ActiveRecord::Base
    self.table_name = "ellie_custom_collections"
end

class EllieProduct < ActiveRecord::Base
    self.table_name = "ellie_products"
end

class EllieVariant < ActiveRecord::Base
    self.table_name = "ellie_variants"
end