package ch.idsia.benchmark.mario.engine.generalization;

public enum Tile {
	/**
	 * ZLevel: 0 only 
	 */
	CANNON_MUZZLE("CM", 14, 0),
	
	/**
	 * ZLevel: 0 only 
	 */
	CANNON_TRUNK("CT", 2, 0),
	
	/**
	 * ZLevel: 0, 1 and 2
	 * 
	 * Represents a coin Mario can collect.
	 */
	COIN_ANIM("C", 3, 0, 1, 2),
	
	/**
	 * ZLevel: 0 only
	 * 
	 * Can be:
	 * -- brick, simple, without any surprise.
     * -- brick with a hidden coin
	 * -- brick with a hidden friendly flower
	 */
	BREAKABLE_BRICK("BB", 4, 0),
	
	/**
	 * ZLevel: 0 only
	 * 
	 * Can be:
	 * -- question brick containing coin
	 * -- question brick containing flower/mushroom
	 * -- question brick containing 0-N coins inside
	 */
	QUESTION_BRICK("BQ", 5, 0),
	
	/**
	 * ZLevel: 1 only
	 * 
	 * Can be:
	 * -- brick, simple, without any surprise.
	 * -- brick with a hidden coin
	 * -- brick with a hidden flower
	 * -- question brick, contains coin
	 * -- question brick, contains flower/mushroom
	 * -- question brick, 0-N coins inside
	 */
	BRICK("B", 6, 1),
	
	/**
	 * ZLevel: 0 only
	 * 
	 * Can be:
	 * -- brick, simple, without any surprise.
	 * -- brick with a hidden coin
	 * -- brick with a hidden flower
	 * -- question brick, contains coin
	 * -- question brick, contains flower/mushroom
	 * -- question brick, 0-N coins inside
	 */
	FLOWER_POT("FP", 7, 0),
	
	/**
	 * ZLevel: 0, 1, 2
	 * 
	 * Represents a SOLID block.
	 */
	BORDER_CANNOT_PASS_THROUGH("BI", 8, 0, 1, 2),
	
	/**
	 * ZLevel: 0, 1
	 * 
	 * Represents a block you can stand on but also jump through (when jumping up) but not fall through.
	 */
	BORDER_HILL("BH", 9, 0, 1),
	
	/**
	 * ZLevel: 1 only
	 * 
	 * Flower pot or a cannon.
	 */
	FLOWER_POT_OR_CANNON("PC", 10, 1),
	
	/**
	 * ZLevel: 0, 1
	 * 
	 * Represents a LADDER block (but not its top)
	 */
	LADDER("L", 11, 0, 1),
	
	/**
	 * ZLevel: 0, 1
	 * 
	 * Represents top of the ladder (you cannot climb up anymore than this).
	 */
	TOP_OF_LADDER("TL", 12, 0, 1),
	
	/**
	 * ZLevel: 0, 1, 2
	 * 
	 * PRINCESS! Congratulation, you will win if you reach her!
	 */
	PRINCESS("P", 13, 1, 2),

	/**
	 * ZLevel: 2 only
	 * 
	 * Nothing, may pass through (if not a hidden block! ... which is, hmm, hidden ;-)
	 */
	NOTHING("", 0, 2),
	
	/**
	 * ZLevel: 2 only
	 * 
	 * Everything else...
	 */
	SOMETHING("S", 1, 2);
		
	private String debug;
	
	private int code;

	private int[] zLevels;
	
	private Tile(String debug, int code, int... zLevels) {
		this.debug = debug;
		this.code = code;
		this.zLevels = zLevels;
	}

	public int getCode() {
		return code;
	}
	
	public int[] getZLevels() {
		return zLevels;
	}
	
	public boolean isZLevel(int zLevel) {
		for (int level : zLevels) {
			if (zLevel == level) return true;
		}
		return false;
	}

	public String getDebug() {
		return debug;
	}
	
}
