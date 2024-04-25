
import excel "D:\Onedrive\OneDrive - Hiroshima University\Todo\221031院内がん登録データ利用\2022-02 広島大学病院v3.xlsx", sheet("データ") cellrange(A2:BD96633) firstrow
save "D:\Onedrive\OneDrive - Hiroshima University\研究・原稿\STATA関連\221220院内癌登録データ\data_2015_21.dta"

	**Table1 患者特性・組織特性を年度別に記述して検討
	gen year3=2 if year==2018|year==2019
	replace year3=3 if year==2020|year==2021
	
**病院ごとにencode
encode  病院等の名称,gen (hospital)

**Stage分類をカテゴリー化
gen UICC_pre = ステージ治療前ＵＩＣＣ
replace UICC_pre=floor(ステージ治療前ＵＩＣＣ/10) if ステージ治療前ＵＩＣＣ<1000
replace UICC_pre=floor((ステージ治療前ＵＩＣＣ-4000)/100) if ステージ治療前ＵＩＣＣ>1000
label define cs 40 "Stage 0" 41 "Stage 1"42 "Stage 2" 43 "Stage 3" 44 "Stage 4" 49 "Unknown" 
label values UICC_pre cs

**発見経緯
label define diag_process 1 "がん検診_健診" 3 "フォロー中" 4 "剖検" 8 "Others" 9 "Unknown"
label values  発見経緯 diag_process

**日付の変換
foreach x in   生存最終確認日 死亡日 生年月日 当該腫瘍初診日{
	replace `x'=. if `x'==77777777
	tostring  `x', replace
gen `x'2 = date(`x', "YMD")
format `x'2 %td
}


***追跡有無
gen follow_yn =1 if 追跡期間2>0 & 追跡期間2!=.
replace follow_yn =0 if 追跡期間2== 0


***追跡期間を365日に変更する
gen 追跡期間365=追跡期間2 if 追跡期間2<366
replace 追跡期間365=365 if 追跡期間2>365


***230408がん種別に評価
recode type2 (15 16=1) (18/20 =2) (34=3) (50 =4) (53 54 =5), gen(type3)
label define ca_type3 1 "上部消化管" 2 "colorectal" 3 "lung" 4 "breast" 5 "uterine"
label values type3 ca_type3


***230408がん種別に解析
log using "stcox catype3,log",replace
  levelsof type3 , local(l)
   	foreach i of local l{
		preserve
		drop if year3==1
		dis `i'
		dis "`:label ca_type3 `i'' year"
		stdescribe if type3==`i'
		strate year  if type3==`i', per(365)
	stcox i.year  if type3==`i', nolog		
	stcox i.year sex age_365  if type3==`i',nolog
	stcox i.year sex age_365 b1.UICC_pre no_treatment if type3==`i',nolog
	
	strate year3  if type3==`i',per(365)
		dis "`:label ca_type3 `i'' year3"
	stcox  year3 sex age_365  if type3==`i',nolog
		dis "`:label ca_type3 `i'' year UICC treatment"
	stcox year3 sex  age_365 b1.UICC_pre no_treatment if type3==`i' ,nolog
		dis "`:label ca_type3 `i'' by year"
	sts graph if type3==`i' ,by(year3) title ("`:label ca_type3 `i'' year")
	
 graph save "Graph" "fig\KM_`i'cancer_year3.gph" , replace
 graph export "fig\KM_`i'cancer_year3.tif", as(tif) name("Graph") replace
dis "`:label ca_type3 `i'' by UICC_pre"
sts test year3 if  type3==`i'
 	sts graph if  type3==`i' ,by(year) title ("`:label ca_type3 `i'' year")
	
 graph save "Graph" "fig\KM_`i'year.gph", replace
 graph export "fig\KM_`i'year.tif", as(tif) name("Graph") replace
 sts test year if  type3==`i'
 restore
 
	}
log close

**Baseline table
	table1_mc if follow_yn==0 & 症例区分!=40, by(year3) ///
vars( ///
  age_365 conts %10.1f \ ///
  sex bin %6.0f \ ///
   UICC_pre cat %6.0f \ ///
     diag_ev cat %6.0f \ ///
	 	discov_ca2 cat %6.0f \ ///
		withdraw  bin %6.0f \ ///
		) ///
nospace  missing  total(before) ///
saving("table_lung_revise_excluded_only.xlsx", replace)

**supplementary table
	table1_mc if  症例区分!=40, by(follow_yn) ///
vars( ///
  age_365 conts %10.1f \ ///
  sex bin %6.0f \ ///
   UICC_pre cat %6.0f \ ///
     diag_ev cat %6.0f \ ///
	 	discov_ca2 cat %6.0f \ ///
		withdraw  bin %6.0f \ ///
		) ///
nospace  missing  total(before) ///
saving("table_lung_revise_follow_up_w_wo.xlsx", replace)