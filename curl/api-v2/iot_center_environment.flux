  from(bucket:"iot_center")
    |> range(start: -100d)
    |> filter(fn: (r) => r._measurement == "environment")
