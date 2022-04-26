import "experimental/http"
import "experimental/json"
import "array"
import "system"
import "math"
import "testing"

fakedata = {"status":"1","message":"OK","result":"1166794681865"}
fakerecords = [fakedata]
faketable = array.from(rows: fakerecords)

action = "ethsupply"
response = http.get(headers: {Accept: "application/json"}, url: "https://api.etherscan.io/api?module=stats&action=${action}&apikey=${ETHERSCAN_API_KEY}")
data = json.parse(data: response.body)
records = [{_value: float(v: data.result)}]

array.from(rows: records)
  |> map(fn: (r) => {
       return { r with
        _measurement: action,
        _time: system.time()
       }
    })
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
  |> yield(name: "mean")
