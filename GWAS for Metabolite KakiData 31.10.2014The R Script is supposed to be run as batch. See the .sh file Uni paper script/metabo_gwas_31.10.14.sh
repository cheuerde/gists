
traits <- c("glycerophosphocholine","phosphocholine","gpcpc")

TRAIT=gpcpc

nohup R --vanilla --quiet --no-save --args $TRAIT < /home/claas/Metabo_11_2013/new_data/meta/script_new_31.10.14.r > /home/claas/Metabo_11_2013/new_data/meta/run_12.11.14_${TRAIT}.Rout &

