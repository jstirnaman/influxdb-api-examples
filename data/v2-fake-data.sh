DATE=`gdate +%s`

fake_points() {
echo "airSensors,sensor_id=TLM0202,lat=40.741895,long=-73.989308 temperature=75.30007505999716,humidity=35.651929918691714,co=0.5141876544505826 ${DATE}" | gzip > air-sensors.gzip
}

fake_bad_points () {
cat <<EOF > air-sensors.lp
airSensors,sensor_id=TLM0201 temperature="73",humidity="35",co=0.48445310567793615 ${DATE} 
airSensors,sensor_id=TLM0202 temperature=75.30007505999716,humidity=35.651929918691714,co=0.5141876544505826 ${DATE}
EOF
}
