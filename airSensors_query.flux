  from(bucket:"airSensors")
    |> range(start: -100d)
    |> filter(fn: (r) => r._measurement == "airSensor")
