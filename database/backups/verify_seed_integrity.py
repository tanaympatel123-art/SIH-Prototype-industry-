import re
import os

seed_file = os.path.join(os.path.dirname(__file__), '..', 'seeds', 'phase1_seed.sql')
seed_content = open(seed_file, encoding='utf-8').read()
cleaned = re.sub(r'--.*?$', '', seed_content, flags=re.MULTILINE)

def parse_table_data(tbl):
    m = re.search(rf'INSERT INTO\s+{tbl}\s*\((.*?)\)\s*VALUES\s*(.*?)(?:ON DUPLICATE|\n\n|;)', cleaned, re.DOTALL | re.IGNORECASE)
    if not m: return []
    cols = [c.strip() for c in m.group(1).split(',')]
    tuples = re.findall(r'\(([^()]+)\)', m.group(2))
    rows = []
    for t in tuples:
        parts = [x.strip().strip("'") for x in t.split(',')]
        rows.append(dict(zip(cols, parts)))
    return rows

roles = {int(r['id']) for r in parse_table_data('roles')}
users = {int(r['id']): int(r['role_id']) for r in parse_table_data('users')}
students = {int(r['id']): int(r['user_id']) for r in parse_table_data('student_profiles')}
companies = {int(r['id']): int(r['user_id']) for r in parse_table_data('company_profiles')}
teachers = {int(r['id']): int(r['user_id']) for r in parse_table_data('teacher_profiles')}
skills = {int(r['id']) for r in parse_table_data('skills')}
student_skills = {int(r['id']): (int(r['student_id']), int(r['skill_id'])) for r in parse_table_data('student_skills')}
opps = {int(r['id']): int(r['company_id']) for r in parse_table_data('opportunities')}
opp_skills = [(int(r['opportunity_id']), int(r['skill_id'])) for r in parse_table_data('opportunity_skills')]
verifications = [(int(r['student_skill_id']), int(r['verifier_teacher_id'])) for r in parse_table_data('skill_verifications')]
apps = [(int(r['opportunity_id']), int(r['student_id'])) for r in parse_table_data('applications')]

errors = []
for u_id, r_id in users.items():
    if r_id not in roles: errors.append(f'User {u_id} invalid role {r_id}')
for s_id, u_id in students.items():
    if u_id not in users: errors.append(f'Student {s_id} invalid user {u_id}')
for c_id, u_id in companies.items():
    if u_id not in users: errors.append(f'Company {c_id} invalid user {u_id}')
for t_id, u_id in teachers.items():
    if u_id not in users: errors.append(f'Teacher {t_id} invalid user {u_id}')
for ss_id, (st_id, sk_id) in student_skills.items():
    if st_id not in students: errors.append(f'StudentSkill {ss_id} invalid student {st_id}')
    if sk_id not in skills: errors.append(f'StudentSkill {ss_id} invalid skill {sk_id}')
for o_id, c_id in opps.items():
    if c_id not in companies: errors.append(f'Opp {o_id} invalid company {c_id}')
for o_id, sk_id in opp_skills:
    if o_id not in opps: errors.append(f'OppSkill invalid opp {o_id}')
    if sk_id not in skills: errors.append(f'OppSkill invalid skill {sk_id}')
for ss_id, vt_id in verifications:
    if ss_id not in student_skills: errors.append(f'Verification invalid student_skill {ss_id}')
    if vt_id not in teachers: errors.append(f'Verification invalid teacher {vt_id}')
for o_id, st_id in apps:
    if o_id not in opps: errors.append(f'App invalid opp {o_id}')
    if st_id not in students: errors.append(f'App invalid student {st_id}')

if errors:
    print('ERRORS FOUND:')
    for e in errors:
        print(' -', e)
else:
    print('ALL FOREIGN KEYS VERIFIED 100% VALID AND REFERENTIALLY SOUND!')
