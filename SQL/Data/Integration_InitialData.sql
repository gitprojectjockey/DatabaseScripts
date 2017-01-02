
BEGIN TRY

BEGIN TRANSACTION 

--INSERT INTO [CWI_ImportDataType]
INSERT [dbo].[CWI_ImportDataType] ([ColumnDataTypeID], [ColumnDataTypeName]) VALUES (1, N'TEXT')
INSERT [dbo].[CWI_ImportDataType] ([ColumnDataTypeID], [ColumnDataTypeName]) VALUES (2, N'NUMBER')
INSERT [dbo].[CWI_ImportDataType] ([ColumnDataTypeID], [ColumnDataTypeName]) VALUES (3, N'DATE')
INSERT [dbo].[CWI_ImportDataType] ([ColumnDataTypeID], [ColumnDataTypeName]) VALUES (4, N'TRUE/FALSE')
INSERT [dbo].[CWI_ImportDataType] ([ColumnDataTypeID], [ColumnDataTypeName]) VALUES (5, N'DECIMAL')
INSERT [dbo].[CWI_ImportDataType] ([ColumnDataTypeID], [ColumnDataTypeName]) VALUES (6, N'CURRENCY')

--INSERT INTO [CWI_ImportFile]
SET IDENTITY_INSERT [dbo].[CWI_ImportFile] ON 

INSERT [dbo].[CWI_ImportFile] ([FileID], [Description]) VALUES (1, N'Social Media Integration File (Facebook)')
INSERT [dbo].[CWI_ImportFile] ([FileID], [Description]) VALUES (2, N'Social Media Integration File (Twitter)')
INSERT [dbo].[CWI_ImportFile] ([FileID], [Description]) VALUES (3, N'Digital Leads Integration File')
INSERT [dbo].[CWI_ImportFile] ([FileID], [Description]) VALUES (4, N'Digital Response Integration File')
INSERT [dbo].[CWI_ImportFile] ([FileID], [Description]) VALUES (5, N'Dummy')
INSERT [dbo].[CWI_ImportFile] ([FileID], [Description]) VALUES (6, N'App Count Report')

SET IDENTITY_INSERT [dbo].[CWI_ImportFile] OFF


--INSERT INTO [CWI_ImportColumn]
SET IDENTITY_INSERT [dbo].[CWI_ImportColumn] ON 

INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (1, N'ClientNameFacebook', N'Client Name', 1, 1, 100, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (2, N'ProductNameFacebook', N'Product Name', 1, 1, 100, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (3, N'DateFacebook', N'Date', 3, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (4, N'ImpressionsFacebook', N'Impressions', 2, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (5, N'ClicksFacebook', N'Clicks', 5, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (6, N'SpendFacebook', N'Spend', 6, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (7, N'PageLikeFacebook', N'Page Like', 2, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (8, N'PageLike28dFacebook', N'Page Like (28d Post Click)', 2, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (9, N'PageLike1dFacebook', N'Page Like (1d Post Impression)', 2, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (10, N'CostPerPageLikeFacebook', N'Cost Per Page Like', 6, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (11, N'ClickToPageLikeFacebook', N'Click To Page Like %', 5, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (12, N'PostLikeFacebook', N'Post Like', 5, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (13, N'PostLike28dFacebook', N'Post Like (28d Post click)', 2, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (14, N'PostLike1dFacebook', N'Post Like (1d Post Impression)', 2, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (15, N'CostPerPostLikeFacebook', N'Cost Per Post Like', 6, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (16, N'ClickToPostLikeFacebook', N'Click To Post Like %', 5, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (17, N'LeadConversionFacebook', N'Lead Conversion', 5, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (18, N'SpendFacebook', N'Spend (Markup)', 6, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (19, N'FacebookVisitsFacebook', N'Facebook Visits', 2, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (20, N'FacebookLeadsFacebook', N'Facebook Leads', 2, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (21, N'FacebookCallsFacebook', N'Facebook Calls', 2, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (22, N'ClientNameTwitter', N'Client Name', 1, 1, 100, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (23, N'DateTwitter', N'Date', 3, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (24, N'ImpressionsTwitter', N'Impressions', 2, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (25, N'ClicksTwitter', N'Clicks', 2, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (26, N'SpendTwitter', N'Spend', 6, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (27, N'EngagementsTwitter', N'Engagements', 2, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (28, N'AccountFollowsTwitter', N'Account Follows', 2, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (29, N'SpendMarkupTwitter', N'Spend (Markup)', 6, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (30, N'VisitsTwitter', N'Visits', 2, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (31, N'LeadsTwitter', N'Leads', 2, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (32, N'CallsTwitter', N'Calls', 2, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (33, N'GrossMediaTwitter', N'Gross Media', 6, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (34, N'Agency', N'Agency (Digital Leads)', 1, 0, 50, N'AAAA')
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (35, N'Report Name', N'Report Name (Digital Leads)', 1, 0, 50, N'AAAA')
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (36, N'Date Range', N'Date Range (Digital Leads)', 1, 0, 150, N'AAAA')
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (37, N'Account Name', N'Account Name (Digital Leads)', 1, 1, 255, N'AAAA')
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (38, N'Apply Now Leads', N'Apply Now Leads', 2, 0, 0, N'####')
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (39, N'Form Leads', N'Form Leads', 2, 0, 0, N'####')
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (40, N'VR Pre-Qualified Leads', N'VR Pre-Qualified Leads', 2, 0, 0, N'####')
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (41, N'VR Not Qualified Leads', N'VR Not Qualified Leads', 2, 0, 0, N'####')
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (42, N'Call Count', N'Call Count', 2, 0, 0, N'####')
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (43, N'Agency', N'Agency (Digital Response)', 1, 0, 50, N'AAAA')
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (44, N'Report Name', N'Report Name (Digital Response)', 1, 0, 50, N'AAAA')
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (45, N'Date Range', N'Date Range (Digital Response)', 1, 0, 150, N'AAAA')
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (46, N'Account Name', N'Account Name (Digital Response)', 1, 1, 255, N'AAAA')
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (47, N'Impr.', N'Impr.', 2, 0, 0, N'####')
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (48, N'Clicks', N'Clicks', 2, 0, 0, N'####')
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (49, N'CTR', N'CTR', 5, 0, 0, N'####')
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (50, N'Avg. CPC (USD)', N'Avg. CPC (USD)', 6, 0, 0, N'####')
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (51, N'Cost (USD)', N'Cost (USD)', 6, 0, 0, N'####')
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (52, N'Total Leads', N'Total Leads', 2, 0, 0, N'####')
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (53, N'CPL (USD)', N'CPL (USD)', 6, 0, 0, N'####')
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (54, N'PaperEmail', N'PaperEmail', 1, 1, 150, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (55, N'PaperPhone', N'PaperPhone', 1, 1, 13, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (56, N'CliCode', N'CliCode', 1, 1, 4, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (57, N'PaperName', N'PaperName', 1, 1, 150, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (58, N'ClientName', N'ClientName', 1, 1, 150, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (59, N'AdDescription', N'AdDescription', 1, 1, 250, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (60, N'BANNER CLICKS', N'BANNER CLICKS', 2, 0, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (61, N'APPS', N'APPS', 2, 0, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (62, N'BANNER CLICKS + APPS', N'BANNER CLICKS + APPS', 2, 0, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (63, N'BY', N'BY', 1, 0, 3, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (64, N'COMMENTS', N'COMMENTS', 1, 0, 500, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (65, N'Year', N'Year', 2, 1, 5, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (66, N'Month2', N'Month2', 2, 1, 2, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (67, N'LeadConversion28dPostClickFacebook', N'Lead Conversion (28d Post Click)', 2, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (69, N'LeadConversion1dPostImpressionFacebook', N'Lead Conversion (1d Post Impression)', 2, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (70, N'CostPerLeadConversionFacebook', N'Cost Per Lead Conversion', 6, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (71, N'ClicktoLeadConversionPercentFacebook', N'Click to Lead Conversion %', 5, 1, NULL, NULL)
INSERT [dbo].[CWI_ImportColumn] ([ColumnID], [ColumnName], [ColumnDisplayName], [ColumnDataType], [Required], [Length], [Format]) VALUES (72, N'LeadConversionValueFacebook', N'Lead Conversion Value', 5, 1, NULL, NULL)
SET IDENTITY_INSERT [dbo].[CWI_ImportColumn] OFF


SET IDENTITY_INSERT [dbo].[CWI_ImportColumnMap] ON 

--INSERT INTO [CWI_ImportColumnMap]
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (1, N'ClientNameFacebook', 1, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 1, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (2, N'ProductNameFacebook', 2, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 1, 2)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (3, N'DateFacebook', 3, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 1, 3)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (4, N'ImpressionsFacebook', 4, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 1, 4)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (5, N'ClicksFacebook', 5, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 1, 5)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (6, N'SpendFacebook', 6, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 1, 6)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (7, N'PageLikeFacebook', 7, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 1, 7)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (8, N'PageLike28dFacebook', 8, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 1, 8)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (9, N'PageLike1dFacebook', 9, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 1, 9)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (10, N'CostPerPageLikeFacebook', 10, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 1, 10)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (11, N'ClickToPageLikeFacebook', 11, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 1, 11)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (12, N'PostLikeFacebook', 12, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 1, 12)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (13, N'PostLike28dFacebook', 13, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 1, 13)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (14, N'PostLike1dFacebook', 14, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 1, 14)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (15, N'CostPerPostLikeFacebook', 15, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 1, 15)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (16, N'ClickToPostLikeFacebook', 16, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 1, 16)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (17, N'LeadConversionFacebook', 17, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 1, 17)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (19, N'FacebookVisitsFacebook', 19, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 1, 23)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (20, N'FacebookLeadsFacebook', 20, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 1, 24)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (21, N'FacebookCallsFacebook', 21, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 1, 25)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (26, N'ClientNameTwitter', 22, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 2, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (27, N'DateTwitter', 23, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 2, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (28, N'ImpressionsTwitter', 24, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 2, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (29, N'ClicksTwitter', 25, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 2, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (30, N'SpendTwitter', 26, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 2, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (31, N'EngagementsTwitter', 27, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 2, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (32, N'AccountFollowsTwitter', 28, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 2, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (33, N'SpendMarkupTwitter', 29, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 2, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (34, N'VisistsTwitter', 30, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 2, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (35, N'LeadsTwitter', 31, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 2, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (36, N'CallsTwitter', 32, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 2, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (37, N'GrossMediaTwitter', 33, CAST(N'2014-08-19 12:02:36.503' AS DateTime), 2, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (39, N'Agency:', 34, CAST(N'2014-08-20 00:00:00.000' AS DateTime), 5, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (40, N'Report Name:', 35, CAST(N'2014-08-20 00:00:00.000' AS DateTime), 5, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (42, N'Date range:', 36, CAST(N'2014-08-20 00:00:00.000' AS DateTime), 5, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (43, N'Account Name', 37, CAST(N'2014-08-20 00:00:00.000' AS DateTime), 3, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (44, N'Apply Now Leads', 38, CAST(N'2014-08-20 00:00:00.000' AS DateTime), 3, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (45, N'Form Leads', 39, CAST(N'2014-08-20 00:00:00.000' AS DateTime), 3, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (46, N'VR Pre-Qualified Leads', 40, CAST(N'2014-08-20 00:00:00.000' AS DateTime), 3, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (47, N'VR Not Qualified Leads', 41, CAST(N'2014-08-20 00:00:00.000' AS DateTime), 3, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (48, N'Call Count', 42, CAST(N'2014-08-20 00:00:00.000' AS DateTime), 3, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (53, N'Agency:', 43, CAST(N'2014-08-20 00:00:00.000' AS DateTime), 5, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (54, N'Report Name:', 44, CAST(N'2014-08-20 00:00:00.000' AS DateTime), 5, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (55, N'Date range:', 45, CAST(N'2014-08-20 00:00:00.000' AS DateTime), 5, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (56, N'Account Name', 46, CAST(N'2014-08-20 00:00:00.000' AS DateTime), 4, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (57, N'Impr.', 47, CAST(N'2014-08-20 00:00:00.000' AS DateTime), 4, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (58, N'Clicks', 48, CAST(N'2014-08-20 00:00:00.000' AS DateTime), 4, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (59, N'CTR', 49, CAST(N'2014-08-20 00:00:00.000' AS DateTime), 4, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (60, N'Avg. CPC (USD)', 50, CAST(N'2014-08-20 00:00:00.000' AS DateTime), 4, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (61, N'Cost (USD)', 51, CAST(N'2014-08-20 00:00:00.000' AS DateTime), 4, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (62, N'Total Leads', 52, CAST(N'2014-08-20 00:00:00.000' AS DateTime), 4, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (63, N'CPL (USD)', 53, CAST(N'2014-08-20 00:00:00.000' AS DateTime), 4, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (66, N'PaperEmail', 54, CAST(N'2014-09-05 00:00:00.000' AS DateTime), 6, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (67, N'PaperPhone', 55, CAST(N'2014-09-05 00:00:00.000' AS DateTime), 6, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (68, N'CliCode', 56, CAST(N'2014-09-05 00:00:00.000' AS DateTime), 6, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (69, N'PaperName', 57, CAST(N'2014-09-05 00:00:00.000' AS DateTime), 6, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (70, N'ClientName', 58, CAST(N'2014-09-05 00:00:00.000' AS DateTime), 6, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (71, N'AdDescription', 59, CAST(N'2014-09-05 00:00:00.000' AS DateTime), 6, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (72, N'BANNER CLICKS', 60, CAST(N'2014-09-05 00:00:00.000' AS DateTime), 6, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (73, N'APPS', 61, CAST(N'2014-09-05 00:00:00.000' AS DateTime), 6, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (74, N'BANNER CLICKS + APPS', 62, CAST(N'2014-09-05 00:00:00.000' AS DateTime), 6, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (75, N'BY', 63, CAST(N'2014-09-05 00:00:00.000' AS DateTime), 6, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (76, N'COMMENTS', 64, CAST(N'2014-09-05 00:00:00.000' AS DateTime), 6, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (77, N'Year', 65, CAST(N'2014-09-05 00:00:00.000' AS DateTime), 6, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (78, N'Month2', 66, CAST(N'2014-09-05 00:00:00.000' AS DateTime), 6, 1)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (84, N'LeadConversion28dPostClickFacebook', 67, CAST(N'2014-09-05 00:00:00.000' AS DateTime), 1, 18)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (88, N'LeadConversion1dPostImpressionFacebook', 69, CAST(N'2014-09-05 00:00:00.000' AS DateTime), 1, 19)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (89, N'CostPerLeadConversionFacebook', 70, CAST(N'2014-09-05 00:00:00.000' AS DateTime), 1, 20)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (91, N'ClicktoLeadConversionPercentFacebook', 71, CAST(N'2014-09-05 00:00:00.000' AS DateTime), 1, 21)
INSERT [dbo].[CWI_ImportColumnMap] ([ColumnMapID], [ImportColumnName], [ColumnID], [CreateDate], [FileID], [Order]) VALUES (92, N'LeadConversionValueFacebook', 72, CAST(N'2014-09-05 00:00:00.000' AS DateTime), 1, 22)
SET IDENTITY_INSERT [dbo].[CWI_ImportColumnMap] OFF



COMMIT TRAN -- Transaction Success!

END TRY
BEGIN CATCH

IF @@TRANCOUNT > 0
	ROLLBACK TRAN 

    DECLARE @ErrorNumber INT = ERROR_NUMBER()
    DECLARE @ErrorLine INT = ERROR_LINE()
	DECLARE @ErrorMessage VARCHAR(MAX) = ERROR_MESSAGE()

    PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10))
    PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10))
	PRINT 'Actual error message: ' + @ErrorMessage

    --THROW @ErroNumber,@ErrorMessage,1;

END CATCH
GO
