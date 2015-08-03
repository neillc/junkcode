"""Quick and dirty tool to remove identifying information from
the la member database.

Written to allow LA to provide a dump of the database with data 
that could be used for testing
"""
import datetime
import random
import faker
from sqlalchemy import create_engine
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import MetaData

import backend.settings


engine = create_engine(backend.settings.db_connection)
base = automap_base()
base.prepare(engine, reflect=True)


metadata = MetaData()

Members = base.classes.members

fake = faker.Factory.create('en_AU')

session = Session(engine)
count = 0
for member in session.query(Members):
    count += 1
    member.first_name = fake.first_name()
    member.last_name = fake.last_name()
    member.middle_name = None
    member.sex = random.choice(['M', 'F'])
    member.address1 = fake.street_address()
    member.address2 = random.choice([None, 'The Mews'])
    member.country = random.choice(['Australia', 'New Zealand'])
    member.DOB = datetime.date(
        random.randrange(1940, 2000),
        random.randrange(1, 12),
        random.randrange(1, 28))
    member.email = fake.email()
    member.postcode = fake.postcode()
    member.phone_home = fake.phone_number()
    member.phone_mobile = fake.phone_number()
    member.state = fake.state()
    member.suburb = fake.city()

session.commit()

print ('{0} items updated'.format(count))

