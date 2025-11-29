create table employees_audit (
	employee_id int,
	name_old varchar(100),
	name_new varchar(100),
	date_modified timestamp default current_timestamp
);

create or replace function register_audit_title()
returns trigger as $$
begin
	insert into employees_audit (employee_id, name_old, name_new)
	values (new.employee_id, old.title, new.title);
	return new;
end;
$$ language plpgsql;

create trigger trg_audit_title
after update of title on employees
for each row
execute function register_audit_title();

create or replace procedure atualize_employee_title(
	p_employee_id int,
	p_new_title varchar(100)
)
as $$ 
begin
	update employees
	set title = p_new_title
	where employee_id = p_employee_id;
end;
$$ language plpgsql;

	call atualize_employee_title(1, 'estagiario');