if exists (select 1 from sys.schemas s join sys.objects o on s.schema_id = o.schema_id and s.name = 'x_FormletView' and o.name = 'Transportation')
drop view x_FormletView.Transportation
go

create view x_FormletView.Transportation
as
select
	ItemID = itm.ID,
	f.CreatedDate,
	i.InstanceID,
	StudentID = stu.ID,
	stu.Number,
	StudentFirstname = stu.Firstname,
	StudentLastname = stu.Lastname,
	--
	Q1 = vv_0_0.Value, --	Medical Equipment (Wheelchair, oxygen, unique seating, etc.) 
	Q2 = vv_0_1.Value, --	Special environment (dust controlled, temperature controlled, tinted windows). 
	Q3 = vv_0_2.Value, --	Aide or monitor is required due to disability and specific need to student. 
	Q4 = vv_0_3.Value, --	Shortened school day is required due to disability and specific need of student. 
	Txt1 = vv_0_4.Value, --	Describe:  
	Txt2 = vv_0_5.Value, --	Describe:  
	Txt3 = vv_0_6.Value, --	Describe:  
	Txt4 = vv_0_7.Value --	Describe:  

from
	Student stu JOIN
	PrgItem itm on stu.ID = itm.StudentID JOIN
	PrgItemDef id on itm.DefID = id.ID JOIN
	PrgItemForm f on f.ItemID = itm.ID JOIN
	FormInstanceInterval i on i.InstanceId = f.ID JOIN
	
	--	Medical Equipment (Wheelchair, oxygen, unique seating, etc.)     < Q1 >    (Flag)
	FormInputValue v_0_0 on
		v_0_0.InputFieldId = 'E48B503F-2936-4DB7-B666-4704E95BCF89' AND
		v_0_0.Intervalid = i.ID JOIN
	FormInputFlagValue vv_0_0 on vv_0_0.ID = v_0_0.ID JOIN

	--	Special environment (dust controlled, temperature controlled, tinted windows).     < Q2 >    (Flag)
	FormInputValue v_0_1 on
		v_0_1.InputFieldId = '73ED618E-447F-450A-A321-16E5BEBBA6B5' AND
		v_0_1.Intervalid = i.ID JOIN
	FormInputFlagValue vv_0_1 on vv_0_1.ID = v_0_1.ID JOIN

	--	Aide or monitor is required due to disability and specific need to student.     < Q3 >    (Flag)
	FormInputValue v_0_2 on
		v_0_2.InputFieldId = 'CC63FCF3-CBBF-43F4-8EFD-457FDE5827F8' AND
		v_0_2.Intervalid = i.ID JOIN
	FormInputFlagValue vv_0_2 on vv_0_2.ID = v_0_2.ID JOIN

	--	Shortened school day is required due to disability and specific need of student.     < Q4 >    (Flag)
	FormInputValue v_0_3 on
		v_0_3.InputFieldId = 'DE828F3F-2352-46C3-9EC0-1BC386E4E6FE' AND
		v_0_3.Intervalid = i.ID JOIN
	FormInputFlagValue vv_0_3 on vv_0_3.ID = v_0_3.ID JOIN

	--	Describe:     < Txt1 >    (Text)
	FormInputValue v_0_4 on
		v_0_4.InputFieldId = '843FA824-0806-4C7F-A9A0-70CC5AB3C6DB' AND
		v_0_4.Intervalid = i.ID JOIN
	FormInputTextValue vv_0_4 on vv_0_4.ID = v_0_4.ID JOIN

	--	Describe:     < Txt2 >    (Text)
	FormInputValue v_0_5 on
		v_0_5.InputFieldId = '9CB0D4AF-0B70-48C8-94B1-B5915FB75EF1' AND
		v_0_5.Intervalid = i.ID JOIN
	FormInputTextValue vv_0_5 on vv_0_5.ID = v_0_5.ID JOIN

	--	Describe:     < Txt3 >    (Text)
	FormInputValue v_0_6 on
		v_0_6.InputFieldId = 'ACA0EA01-C679-41B3-8FA0-295D54A85551' AND
		v_0_6.Intervalid = i.ID JOIN
	FormInputTextValue vv_0_6 on vv_0_6.ID = v_0_6.ID JOIN

	--	Describe:     < Txt4 >    (Text)
	FormInputValue v_0_7 on
		v_0_7.InputFieldId = 'B7D8F535-3F81-4041-A772-3389F1D1E7EB' AND
		v_0_7.Intervalid = i.ID JOIN
	FormInputTextValue vv_0_7 on vv_0_7.ID = v_0_7.ID

 
go
