
   Insert Into  [CarGarageManagerDb].[dbo].[Image](ImageName, ImageContent)
   Select 'BrakeDiscs.jpg', BulkColumn 
   from Openrowset (Bulk 'C:\@EDevelopment\ESourceCode\ASP\GarageWebShop\CarGarageManager\CarGarageManager\Images\Products\BrakeDiscs.jpg', Single_Blob) as Image