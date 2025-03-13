//• Listar por Produto o “histórico de vendas” adquiridos pelo cliente;
db.sales.aggregate([
  {
    $unwind: "$saleStocks"
  },
  {
      $group: {
          _id:"$saleStocks.stockId",
          count: {$sum: 1}
      }
  },
  {
    $project: {
      "Stock Id": "$_id",
      "Numero de Sales": "$count",
      _id: 0
    }
  }
])
//• Listar por Produto o valor total por mês/ano e a média mensal;
db.sales.aggregate([
    {
    $unwind: "$saleStocks"
  },{
        $addFields: {
            "saleStocks.invoiceDate": {$toDate: "$invoinceDate"}
        }
  },{
    $group: {
      _id: { stockId: "$saleStocks.stockId", year: { $year: "$saleStocks.invoiceDate" } },
      totalSales: { $sum: { $multiply: ["$saleStocks.quantity", "$saleStocks.unitPrice"] } }
    }
  },
  {
    $project: {
      StockId: "$_id.stockId",
      year: "$_id.year",
      totalSales: {$round: [ "$totalSales", 2]},
      averageSale: {$round: [{ $divide: [ "$totalSales", 12 ] }, 2]},
      _id: 0
    }
  },
  {
    $sort: { StockId: 1 }
  }
])
//• Listar por Marca, os produtos e quantidades adquiridas.
db.sales.aggregate([
  {
    $unwind: "$saleStocks"
  },
  {
    $group: {
      _id: "$saleStocks.brand",
      stocks:{$push: {stockId:"$saleStocks.stockId" ,quantity:{$sum:"$saleStocks.quantity"}}}
    }
  },
  {
    $project: {
      brand: "$_id",
      stocks: 1,
      _id: 0
    }
  }
])
//• Obter o nº médio de dias por empresa de logística;
db.transports.aggregate([
    
    {
        $unwind: "$transport"
        
    },{
        $addFields: {
            "transport.name": "$name"
        }
    },
    {
        $replaceRoot: {
            newRoot: "$transport"
        }
    },
    {
        $group: {
            _id: "$name",
            days:  {
                $sum:{ 
                    $subtract: [
                        {$sum:[{$dayOfYear:  {$toDate: "$deliveryDate" }}, {$multiply: [ {$year:  {$toDate: "$deliveryDate" }}, 365]]},
                        {$sum:[{$dayOfYear:  {$toDate: "$shippingDate" }}, {$multiply: [ {$year:  {$toDate: "$shippingDate" }}, 365]]} 
                    ]
                }
            },
            count: {$sum:1}
            
        }
    },
    {
        $project: {
            name: "$_id",
            avg: {$round: [{$divide: ["$days", "$count"]}, 2]},
            sumOfDays: "$days"
            count: "$count",
            _id:0
        }
    }
])

//• Nº de transportes por empresa de logística.
db.transports.aggregate([
   {
      $project: {
         _id: "$name",
         count: { $size: "$transport"}
      }
   }
])
//Query para exportação da coleção transports
db.transports.aggregate([
    
    {
        $unwind: "$transport"
        
    },{
        $addFields: {
            "transport.name": "$name"
        }
    },
    {
        $replaceRoot: {
            newRoot: "$transport"
        }
    }
])