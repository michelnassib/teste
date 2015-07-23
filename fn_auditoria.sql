
-- Function: polis.fn_auditoria()

-- DROP FUNCTION polis.fn_auditoria();

CREATE OR REPLACE FUNCTION polis.fn_auditoria()
  RETURNS trigger AS
$BODY$
DECLARE
	vregistro RECORD;
	vid_seq INTEGER;
	vdt_op TIMESTAMP;
	vop CHARACTER(1);
	vus_op CHARACTER(50);
	vid_op INTEGER;
BEGIN
	vid_seq := NEXTVAL('polis.seq_audit')::integer;
	vdt_op := DATE_TRUNC('SECOND', NOW());
	vus_op := current_user;
	
	IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
		vregistro = NEW;
		vid_op := NEW.objectid;
		vop := 'I';
		IF (TG_OP = 'UPDATE') THEN
			vop := 'A';
		END IF;
	END IF;

	IF (TG_OP = 'DELETE') THEN
		vregistro = OLD;
		vid_op := OLD.objectid;
		vop := 'E';
	END IF;

	IF (TG_TABLE_NAME = 'lotes') THEN
		INSERT INTO polis.lotes_h(objectid, dti_op, us_op, id_op, op, shape, proprietario, iq1, iq2)
		SELECT vid_seq, vdt_op, vus_op, vid_op, vop, vregistro.shape, vregistro.proprietario, vregistro.iq1, vregistro.iq2;
	END IF;

	IF (TG_TABLE_NAME = 'vias') THEN
		INSERT INTO polis.vias_h(objectid, dti_op, us_op, id_op, op, shape, nomelog, lei) 
		SELECT vid_seq, vdt_op, vus_op, vid_op, vop, vregistro.shape, vregistro.nomelog, vregistro.lei;
	END IF;

	RETURN vregistro;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION polis.fn_auditoria()
  OWNER TO postgres;
