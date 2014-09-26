
if object_id('x_DATATEAM.StudentPrgInvolvementHistory') is not null
drop view x_DATATEAM.StudentPrgInvolvementHistory
go

create view x_DATATEAM.StudentPrgInvolvementHistory
as
select Program = p.name,
	StudentNumber = s.Number, s.Firstname, s.Lastname, 
	InvolvementID = pinv.ID, InvolvementStartDate = pinv.StartDate, InvolvementEndDate = pinv.EndDate, InvolvementEndStatusID = pinv.EndStatus, InvolvementEndStatus = pinvs.Name,
		InvolvementDays = datediff(dd, pinv.StartDate, pinv.EndDate), 
	ItemID = itm.ID, ItemDefID = itm.DefID, Item = itmd.Name, ItemStartDate = itm.StartDate, ItemEndDate = itm.EndDate, ItemEndedDate = itm.EndedDate, ItemStartStatus = ib.Name, ItemEndStatusSequence = ie.Sequence, itm.PlannedEndDate, ItemIsEnded = itm.IsEnded, ItemEndStatus = ie.Name,  
	itm.ItemOutcomeID, ItemOutcome = o.Text, o.Sequence, 
	pinv.StudentID
from Program p
join PrgInvolvement pinv on p.ID = pinv.ProgramID
join Student s on pinv.StudentID = s.ID
join PrgItem itm on pinv.ID = itm.InvolvementID
join PrgItemDef itmd on itm.DefID = itmd.ID
left join PrgStatus ib on itm.StartStatusID = ib.ID
left join PrgStatus ie on itm.EndStatusID = ie.ID
left join PrgItemOutcome o on itm.ItemOutcomeId = o.ID
left join PrgStatus pinvs on pinv.EndStatus = pinvs.ID
go


