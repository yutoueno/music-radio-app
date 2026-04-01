"""add genre to programs

Revision ID: c1a4e5f8d2b3
Revises: b0632103b2a7
Create Date: 2026-03-31 22:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = 'c1a4e5f8d2b3'
down_revision: Union[str, None] = 'b0632103b2a7'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('programs', sa.Column('genre', sa.String(length=100), nullable=True))
    op.create_index(op.f('ix_programs_genre'), 'programs', ['genre'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_programs_genre'), table_name='programs')
    op.drop_column('programs', 'genre')
