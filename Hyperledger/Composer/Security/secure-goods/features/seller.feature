#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

Feature: SellerSecurity

    Background:
        Given I have deployed the business network definition ..
        And I have added the following participants of type com.makotogo.learn.composer.securegoods.participant.Buyer
            | id   | name |
            | BUY001 | Buyer1 |
        And I have added the following participants of type com.makotogo.learn.composer.securegoods.participant.Seller
            | id   | name |
            | SELL001 | Seller1 |
            | SELL002 | Seller2 |
        And I have added the following participants of type com.makotogo.learn.composer.securegoods.participant.Shipper
            | id   | name |
            | SHIP001 | Shipper1 |
        And I have added the following assets of type com.makotogo.learn.composer.securegoods.asset.Item
            | id | sku | description |
            | WIDGET001 | W001 | Widget number 1 |
            | WIDGET002 | W002 | Widget number 2 |
        And I have added the following assets
        """
        {
            "$class": "com.makotogo.learn.composer.securegoods.asset.Order",
            "id": "ORD0000001",
            "item": "WIDGET001",
            "quantity": "1000",
            "unitCost": {
                "$class": "com.makotogo.learn.composer.securegoods.common.Price",
                "currency": "USD", "amount": "1.5" 
            },
            "buyer": "BUY001",
            "seller": "SELL001",
            "shipper": "SHIP001",
            "shippingCost": {
                "$class": "com.makotogo.learn.composer.securegoods.common.Price",
                "currency": "USD", "amount": "100" 
            },
            "status": "PLACED"
        }
        """
        And I have issued the participant com.makotogo.learn.composer.securegoods.participant.Seller#SELL001 with the identity SELLER001
        And I have issued the participant com.makotogo.learn.composer.securegoods.participant.Seller#SELL002 with the identity SELLER002

    Scenario: Seller 1 can read its own Seller record
        When I use the identity SELLER001
        Then I should have the following participants of type com.makotogo.learn.composer.securegoods.participant.Seller
            | id   | name |
            | SELL001 | Seller1 |

    Scenario: Seller 1 can update its own Seller record
        When I use the identity SELLER001
        And I update the following participants of type com.makotogo.learn.composer.securegoods.participant.Seller
            | id   | name |
            | SELL001 | Seller1-UPDATED |
        Then I should have the following participants of type com.makotogo.learn.composer.securegoods.participant.Seller
            | id   | name |
            | SELL001 | Seller1-UPDATED |

    Scenario: Seller 2 cannot update Seller 1's record
        When I use the identity SELLER002
        And I update the following participants of type com.makotogo.learn.composer.securegoods.participant.Seller
            | id   | name |
            | SELL001 | Seller1-UPDATED |
        Then I should get an error matching /does not have .* access to resource/

    Scenario: Seller 1 can read all Items
        When I use the identity SELLER001
        Then I should have the following assets of type com.makotogo.learn.composer.securegoods.asset.Item
            | id | sku | description |
            | WIDGET001 | W001 | Widget number 1 |
            | WIDGET002 | W002 | Widget number 2 |

    Scenario: Seller cannot access Buyer's Participant Record
        When I use the identity SELLER001
        And I attempt to read the following participants of type com.makotogo.learn.composer.securegoods.participant.Buyer
            | id   | name |
            | BUY001 | Buyer1 |
        Then I should get an error matching /does not have .* access to resource/

    Scenario: Seller cannot access Shipper's Participant Record
        When I use the identity SELLER001
        And I attempt to read the following participants of type com.makotogo.learn.composer.securegoods.participant.Shipper
            | id   | name |
            | SHIP001 | Shipper1 |
        Then I should get an error matching /does not have .* access to resource/

    Scenario: Seller 1 can access their own Order
        When I use the identity SELLER001
        Then I should have the following assets
        """
        {
            "$class": "com.makotogo.learn.composer.securegoods.asset.Order",
            "id": "ORD0000001",
            "item": "WIDGET001",
            "quantity": "1000",
            "unitCost": {
                "$class": "com.makotogo.learn.composer.securegoods.common.Price",
                "currency": "USD", "amount": "1.5" 
            },
            "buyer": "BUY001",
            "seller": "SELL001",
            "shipper": "SHIP001",
            "shippingCost": {
                "$class": "com.makotogo.learn.composer.securegoods.common.Price",
                "currency": "USD", "amount": "100" 
            },
            "status": "PLACED"
        }
        """

    Scenario: Seller 2 cannot access Seller 1's Orders
        When I use the identity SELLER002
        And I attempt to read the following assets
        """
        {
            "$class": "com.makotogo.learn.composer.securegoods.asset.Order",
            "id": "ORD0000001",
            "item": "WIDGET001",
            "quantity": "1000",
            "unitCost": {
                "$class": "com.makotogo.learn.composer.securegoods.common.Price",
                "currency": "USD", "amount": "1.5" 
            },
            "buyer": "BUY001",
            "seller": "SELL001",
            "shipper": "SHIP001",
            "shippingCost": {
                "$class": "com.makotogo.learn.composer.securegoods.common.Price",
                "currency": "USD", "amount": "100" 
            },
            "status": "PLACED"
        }
        """
        Then I should get an error matching /does not have .* access to resource/

    Scenario: Seller 1 can invoke the PlaceOrder transaction
        When I use the identity SELLER001
        And I submit the following transaction
        """
        { 
            "$class": "com.makotogo.learn.composer.securegoods.asset.PlaceOrder",
            "item": "WIDGET001",
            "quantity": "1000",
            "unitCost": {
                "$class": "com.makotogo.learn.composer.securegoods.common.Price",
                "currency": "USD", "amount": "1.5" 
            },
            "buyer": "BUY001",
            "seller": "SELL001",
            "shipper": "SHIP001",
            "shippingCost": {
                "$class": "com.makotogo.learn.composer.securegoods.common.Price",
                "currency": "USD", "amount": "100" 
            }
        }
        """
        Then I should have the following assets
        """
        {
            "$class": "com.makotogo.learn.composer.securegoods.asset.Order",
            "id": "ORD0000100",
            "item": "WIDGET001",
            "quantity": "1000",
            "unitCost": {
                "$class": "com.makotogo.learn.composer.securegoods.common.Price",
                "currency": "USD", "amount": "1.5" 
            },
            "buyer": "BUY001",
            "seller": "SELL001",
            "shipper": "SHIP001",
            "shippingCost": {
                "$class": "com.makotogo.learn.composer.securegoods.common.Price",
                "currency": "USD", "amount": "100" 
            },
            "status": "PLACED"
        }
        """
        And I should have received the following event
        """
        {
            "$class": "com.makotogo.learn.composer.securegoods.asset.OrderPlaced",
            "message": "Order ORD0000100 placed.",
            "order": "ORD0000100"
        }
        """

    Scenario: Seller 2 cannot invoke the PlaceOrder transaction for Seller 1's order
        When I use the identity SELLER002
        And I submit the following transaction
        """
        { 
            "$class": "com.makotogo.learn.composer.securegoods.asset.PlaceOrder",
            "item": "WIDGET001",
            "quantity": "1000",
            "unitCost": {
                "$class": "com.makotogo.learn.composer.securegoods.common.Price",
                "currency": "USD", "amount": "1.5" 
            },
            "buyer": "BUY001",
            "seller": "SELL001",
            "shipper": "SHIP001",
            "shippingCost": {
                "$class": "com.makotogo.learn.composer.securegoods.common.Price",
                "currency": "USD", "amount": "100" 
            }
        }
        """
        Then I should get an error matching /does not have .* access to resource/