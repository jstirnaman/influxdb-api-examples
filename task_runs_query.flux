  from(bucket:"_tasks")
    |> range(start: -100d)
    |> filter(fn: (r) => r._measurement == "_runs")