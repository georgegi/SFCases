
select 
	--StudentName = NULL,
	StudentFirstName = s.Firstname,
	StudentLastName = s.Lastname,
	StudentNumber = s.Number,
	School  = isnull(sch.name, ''), --(service)
	FEFPProgram  = id.Name, -- (? grade level grouping)
	N999 = case sch.ID when 'C3666321-0EA5-4627-9DB5-4ABFB00A9F22' then 1 else 0 end,
	ESY = esyyn.DisplayValue,
	InitialMedicaidPermissionDate  = isnull(convert(varchar, mh.StartDate, 101), ''),
--IEPDates:
	IEPPlanDate = convert(varchar, i.StartDate, 101),
	IEPExpirationDate = convert(varchar, I.PlannedEndDate, 101),
	ReEvaluationDueDate = convert(varchar, dat.NextEvaluationDate, 101),
-- ???
	TTSW = '',
	TNDP = '',
--LRE 
LREPlacement = po.Text,
	--60DayException = NULL,

	Bogus = NULL
from Student s
join PrgInvolvement inv on s.ID = inv.StudentID and inv.ProgramID = 'F98A8EF2-98E2-4CAC-95AF-D7D89EF7F80C' and inv.EndDate is null
join PrgItem i on s.ID = i.StudentID and i.InvolvementID = inv.ID and i.EndDate is null
join PrgItemDef id on i.DefID = id.ID and id.TypeID = 'A5990B5E-AFAD-4EF0-9CCA-DC3685296870' -- IEP
join PrgSection sesy on i.ID = sesy.ItemID
join IepEsy iesy on sesy.ID = iesy.ID
join EnumValue esyyn on iesy.DecisionID = esyyn.ID
join PrgSection sdat on i.ID = sdat.ItemID
join IepDates dat on sdat.ID = dat.ID
left join School sch on s.CurrentSchoolID = sch.ID
left join MedicaidEligibilityHistory mh on s.ID = mh.StudentID and 
	mh.ID = (
	select top 1 m.ID
	from MedicaidEligibilityHistory m
	where s.ID = m.StudentID
	order by m.StartDate asc) -- 4887
left join PrgSection plre on i.ID = plre.ItemID and plre.DefID in (select ID from PrgSectionDef where TypeID = 'D1C4004B-EF82-4E8F-BA12-D8F086EB9BBE') -- 4927
left join IepPlacement lre on plre.ID = lre.InstanceID -- 4947
-- join IepPlacement_AsOfDate (getdate()) pa on lre.ID = pa.ID -- in testing with old database (almost 10 months), we may be seeing a reduced rowcount (???)
left join IepPlacementOption po on lre.OptionID = po.ID

--select * from PrgSectionType where name = 'IEP LRE'


-- select * from IepLeastRestrictiveEnvironment
-- select * from IepPlacement_AsOfDate (getdate()) pa 




--declare @inv uniqueidentifier ; set @inv = 'FD38AFFA-FFA1-4B82-BCA3-0001233011BE'
--select * from PrgInvolvement where ID = @inv
--select * from PrgInvolvementPeriod where InvolvementID = @inv


-- select * from iepdates


--select po.StateCode, po.Text 
--from IepPlacement_AsOfDate (getdate()) pa
--join IepPlacement p on pa.ID = p.ID
--join iepplacementoption po on p.optionid = po.ID








--select * from iepdisabilityeligibility

--select * from iepeligibilitydetermination

--select * from PrgItemForm where ID= 'C2D7CDC0-99C9-40B7-846B-4566E9F21942'
--select * from FormInstance where ID= 'C2D7CDC0-99C9-40B7-846B-4566E9F21942'
--select * from FormTemplate where ID = 'BCE555F3-DB65-4768-BA8B-EA90DC21562E'

select 
	--StudentName = NULL,
	StudentFirstName = s.Firstname,
	StudentLastName = s.Lastname,
	StudentNumber = s.Number,
	FEFPProgram  = id.Name, -- (? grade level grouping)
	IEPPlanDate = convert(varchar, i.StartDate, 101),
-- Disability Data
	EvaluationDate = convert(varchar, ed.DateDetermined, 101),
	Exceptionality = d.Name,
	ENS = ed.NoneSuspected,	--?
	ConsentDate = isnull(convert(varchar, con.ConsentDate, 101), ''),
	EligibilityDate = convert(varchar, ed.DateDetermined, 101)
from Student s
join PrgInvolvement inv on s.ID = inv.StudentID and inv.ProgramID = 'F98A8EF2-98E2-4CAC-95AF-D7D89EF7F80C' and inv.EndDate is null
join PrgItem i on s.ID = i.StudentID and i.InvolvementID = inv.ID and i.EndDate is null
join PrgItemDef id on i.DefID = id.ID and id.TypeID = 'A5990B5E-AFAD-4EF0-9CCA-DC3685296870' -- IEP
join PrgSection sdis on i.ID = sdis.ItemID
join IepEligibilityDetermination ed on sdis.id = ed.ID
join IepDisabilityEligibility de on ed.ID = de.InstanceID and de.PrimaryOrSecondaryID = 'AF6825FF-336C-42CE-AF57-CD095CD0DD2C'
join IepDisability d on de.DisabilityID = d.ID
-- consent for eval
join PrgSection scon on i.ID = scon.ItemID 
join PrgConsent con on scon.ID = con.ID and scon.DefID = '47958E63-10C4-4124-A5BA-8C1077FB2D40' -- Sped Consent Evaluation

--select * from EnumValue where ID = 'AF6825FF-336C-42CE-AF57-CD095CD0DD2C'

-- select * from PrgConsent

--  exec x_datateam.findguid '89E5C405-8014-4953-8027-0002A6BA9BE1'


select 
	--StudentName = NULL,
	StudentFirstName = s.Firstname,
	StudentLastName = s.Lastname,
	StudentNumber = s.Number,
	FEFPProgram  = id.Name, -- (? grade level grouping)
	IEPPlanDate = convert(varchar, i.StartDate, 101),
-- Services Data

	Bogus = ''
from Student s
join PrgInvolvement inv on s.ID = inv.StudentID and inv.ProgramID = 'F98A8EF2-98E2-4CAC-95AF-D7D89EF7F80C' and inv.EndDate is null
join PrgItem i on s.ID = i.StudentID and i.InvolvementID = inv.ID and i.EndDate is null
join PrgItemDef id on i.DefID = id.ID and id.TypeID = 'A5990B5E-AFAD-4EF0-9CCA-DC3685296870' -- IEP
join PrgSection ssrv on i.ID = ssrv.ItemID --- and ssrv.DefID in (select ID from PrgSectionDef where TypeID = '54228EE4-3A8C-4544-9216-D842BE7B0A3B') -- Item Services -- only 604?
join PrgServices srv on ssrv.ID = srv.ID -- 604 records (did Bay not convert Services?)


select * from legacysped.Service

select * from legacysped.Transform_IepService

select * from legacysped.MAP_ServicePlanID -- NULL. Apparently we did not import services!









--select * from PrgSectionType where name like '%Serv%'

select * from PrgServices




	----EligibilityData:
	--Exceptionality = NULL,
	--ENS = NULL,--?
	--ConsentDate = NULL,
	--EligibilityDate = NULL,
	--EvaluationDate = NULL,

	--PlacementDate = NULL,
	--DismissalDate = NULL, -- so it appears they need exited students

	----Services:
	--Service = NULL,
	--MinutesPerWeek = NULL,
	--Provider = NULL,

	--TotalServiceMinutesPerWeek = NULL,


	--AssessmentType  = NULL,--(?)
	--TestAccom = NULL,-- (multiple?)



	----Transportation checkboxes:
	--MedicalEquipment = NULL,
	--BusAideOrMonitor = NULL,
	--MedicalCondition = NULL,
	--ShortenedDay = NULL,
	--AttendsSchoolInANeighboringDistrict = NULL






