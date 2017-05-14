## GDAX Buyer

This simple app allows you to buy up cryptocurrency by creating and removing limit orders just under the last trade price on gdax.com.

# Build

Create a .env file with:

```
# required
GDAX_API_KEY=
GDAX_API_SECRET=
GDAX_API_PASS=

# optional
USD_POOL= # maximum about of usd to have out in orders
MAX_ORDERS= # maximum number of limit orders to leave out on the market
BUY_SIZE= # size per buy order
DISCOUNT= # percentage discount per buy
CURRENCY= # currency out of LTC, BTC, ETH
```

```
docker build -t gdax-buyer .
```

# Run

```
# background
docker run -it -d --restart always --name buyer-ltc --env-file .env gdax-buyer

# foreground
docker run -it --rm --name buyer-ltc --env-file .env gdax-buyer
```
