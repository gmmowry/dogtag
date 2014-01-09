class PaymentRequirement < Requirement

  has_many :tiers, :foreign_key => :requirement_id

  def meets_criteria?

  end

  def active_tier
    selected_tier = chronological_tiers.select { |tier| tier.begin_at < Time.now }.last
    selected_tier ||= false
  end

  private

  def chronological_tiers
    tiers.sort_by(&:begin_at)
  end
end