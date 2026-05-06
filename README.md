{
    "success": true,
    "message": "Valid coupons retrieved successfully",
    "data": [
        {
            "id": 6,
            "coupon_id": "RL-C-0003",
            "coupon_code": "SAVE20",
            "discount_type": "Percentage",
            "discount_value": 20,
            "max_discount": "500.00",
            "min_order_val": "100.00",
            "max_users": 10,
            "used_count": 1,
            "valid_from": "2026-02-26",
            "valid_till": "2026-09-30",
            "applies_to": "All Test",
            "status": "Active",
            "coupon_description": "Test",
            "created_at": "2026-04-24 10:46:16",
            "updated_at": "2026-04-24 10:46:16"
        },
        {
            "id": 4,
            "coupon_id": "RL-C-0001",
            "coupon_code": "WELCOME10",
            "discount_type": "Percentage",
            "discount_value": 10,
            "max_discount": "10.00",
            "min_order_val": "800.00",
            "max_users": 100,
            "used_count": 0,
            "valid_from": "2026-04-26",
            "valid_till": "2026-05-30",
            "applies_to": "All Test",
            "status": "Active",
            "coupon_description": "Test1",
            "created_at": "2026-04-24 08:00:16",
            "updated_at": "2026-04-24 08:00:16"
        }
    ],
    "total": 2
}

this is the api response for fetching all the available coupons and the api is this one

/api/user/get_coupons

if there is no coupon this is the reponse
{
    "success": true,
    "message": "Valid coupons retrieved successfully",
    "data": [],
    "total": 0
}

please implemeent this during booking time like generally in apps during booking during payment list of available coupons shown up right in that maner here also during lab booking and the current flow