"""add_inquiries_table

Revision ID: 96587b1e8a23
Revises: 265cff3605e3
Create Date: 2026-04-01 10:31:29.364195

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '96587b1e8a23'
down_revision: Union[str, None] = '265cff3605e3'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table('inquiries',
    sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
    sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=True),
    sa.Column('email', sa.String(length=255), nullable=False),
    sa.Column('subject', sa.String(length=255), nullable=False),
    sa.Column('body', sa.Text(), nullable=False),
    sa.Column('status', sa.Enum('pending', 'in_progress', 'resolved', 'closed', name='inquiry_status'), nullable=False),
    sa.Column('admin_note', sa.Text(), nullable=True),
    sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='SET NULL'),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_inquiries_status'), 'inquiries', ['status'], unique=False)
    op.create_index(op.f('ix_inquiries_user_id'), 'inquiries', ['user_id'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_inquiries_user_id'), table_name='inquiries')
    op.drop_index(op.f('ix_inquiries_status'), table_name='inquiries')
    op.drop_table('inquiries')
    sa.Enum('pending', 'in_progress', 'resolved', 'closed', name='inquiry_status').drop(op.get_bind())
